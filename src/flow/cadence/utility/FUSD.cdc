import FungibleToken from "./FungibleToken.cdc"

access(all) contract FUSD: FungibleToken {

    // Event that is emitted when the contract is created
    access(all) event TokensInitialized(initialSupply: UFix64)

    // Event that is emitted when tokens are withdrawn from a Vault
    access(all) event TokensWithdrawn(amount: UFix64, from: Address?)

    // Event that is emitted when tokens are deposited to a Vault
    access(all) event TokensDeposited(amount: UFix64, to: Address?)

    // Event that is emitted when new tokens are minted
    access(all) event TokensMinted(amount: UFix64)

    // The storage path for the admin resource
    access(all) let AdminStoragePath: StoragePath

    // The storage Path for minters' MinterProxy
    access(all) let MinterProxyStoragePath: StoragePath

    // The public path for minters' MinterProxy capability
    access(all) let MinterProxyPublicPath: PublicPath

    // Event that is emitted when a new minter resource is created
    access(all) event MinterCreated()

    // Total supply of fusd in existence
    access(all) var totalSupply: UFix64

    // Vault
    //
    // Each user stores an instance of only the Vault in their storage
    // The functions in the Vault are governed by the pre and post conditions
    // in FungibleToken when they are called.
    // The checks happen at runtime whenever a function is called.
    //
    // Resources can only be created in the context of the contract that they
    // are defined in, so there is no way for a malicious user to create Vaults
    // out of thin air. A special Minter resource needs to be defined to mint
    // new tokens.
    //
    access(all) resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {

        // holds the balance of a users tokens
        access(all) var balance: UFix64

        // initialize the balance at resource creation time
        init(balance: UFix64) {
            self.balance = balance
        }

        // withdraw
        //
        // Function that takes an integer amount as an argument
        // and withdraws that amount from the Vault.
        // It creates a new temporary Vault that is used to hold
        // the money that is being transferred. It returns the newly
        // created Vault to the context that called so it can be deposited
        // elsewhere.
        //
        access(all) fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        // deposit
        //
        // Function that takes a Vault object as an argument and adds
        // its balance to the balance of the owners Vault.
        // It is allowed to destroy the sent Vault because the Vault
        // was a temporary holder of the tokens. The Vault's balance has
        // been consumed and therefore can be destroyed.
        access(all) fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @FUSD.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        destroy() {
            FUSD.totalSupply = FUSD.totalSupply - self.balance
        }
    }

    // createEmptyVault
    //
    // Function that creates a new Vault with a balance of zero
    // and returns it to the calling context. A user must call this function
    // and store the returned Vault in their storage in order to allow their
    // account to be able to receive deposits of this token type.
    //
    access(all) fun createEmptyVault(): @FUSD.Vault {
        return <-create Vault(balance: 0.0)
    }

    // Minter
    //
    // Resource object that can mint new tokens.
    // The admin stores this and passes it to the minter account as a capability wrapper resource.
    //
    access(all) resource Minter {

        // mintTokens
        //
        // Function that mints new tokens, adds them to the total supply,
        // and returns them to the calling context.
        //
        access(all) fun mintTokens(amount: UFix64): @FUSD.Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero"
            }
            FUSD.totalSupply = FUSD.totalSupply + amount
            emit TokensMinted(amount: amount)
            return <-create Vault(balance: amount)
        }

    }

    access(all) resource interface MinterProxyPublic {
        access(all) fun setMinterCapability(cap: Capability<&Minter>)
    }

    // MinterProxy
    //
    // Resource object holding a capability that can be used to mint new tokens.
    // The resource that this capability represents can be deleted by the admin
    // in order to unilaterally revoke minting capability if needed.

    access(all) resource MinterProxy: MinterProxyPublic {

        // access(self) so nobody else can copy the capability and use it.
        access(self) var minterCapability: Capability<&Minter>?

        // Anyone can call this, but only the admin can create Minter capabilities,
        // so the type system constrains this to being called by the admin.
        access(all) fun setMinterCapability(cap: Capability<&Minter>) {
            self.minterCapability = cap
        }

        access(all) fun mintTokens(amount: UFix64): @FUSD.Vault {
            return <- self.minterCapability!
            .borrow()!
            .mintTokens(amount:amount)
        }

        init() {
            self.minterCapability = nil
        }

    }

    // createMinterProxy
    //
    // Function that creates a MinterProxy.
    // Anyone can call this, but the MinterProxy cannot mint without a Minter capability,
    // and only the admin can provide that.
    //
    access(all) fun createMinterProxy(): @MinterProxy {
        return <- create MinterProxy()
    }

    // Administrator
    //
    // A resource that allows new minters to be created
    //
    // We will only want one minter for now, but might need to add or replace them in future.
    // The Minter/Minter Proxy structure enables this.
    // Ideally we would create this structure in a single function, generate the paths from the address
    // and cache all of this information to enable easy revocation but String/Path comversion isn't yet supported.
    //
    access(all) resource Administrator {

        // createNewMinter
        //
        // Function that creates a Minter resource.
        // This should be stored at a unique path in storage then a capability to it wrapped
        // in a MinterProxy to be stored in a minter account's storage.
        // This is done by the minter account running:
        // transactions/FUSD/minter/setup_minter_account.cdc
        // then the admin account running:
        // transactions/flowArcaddeToken/admin/deposit_minter_capability.cdc
        //
        access(all) fun createNewMinter(): @Minter {
            emit MinterCreated()
            return <- create Minter()
        }

    }

    init(adminAccount: AuthAccount) {
        self.AdminStoragePath = /storage/fusdAdmin
        self.MinterProxyPublicPath = /public/fusdMinterProxy
        self.MinterProxyStoragePath = /storage/fusdMinterProxy

        self.totalSupply = 0.0

        let admin <- create Administrator()
        adminAccount.save(<-admin, to: self.AdminStoragePath)

        // Emit an event that shows that the contract was initialized
        emit TokensInitialized(initialSupply: 0.0)
    }
}
