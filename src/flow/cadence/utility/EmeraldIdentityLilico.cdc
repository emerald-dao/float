// Welcome to the EmeraldIdentity contract!
//
// This contract is a service that maps a user's on-chain 
// LILICO address to their DiscordID. 
//
// A user cannot configure their own EmeraldID. It must be done 
// by someone who has access to the Administrator resource.
//
// A user can only ever have 1 address mapped to 1 DiscordID, and
// 1 DiscordID mapped to 1 address. This means you cannot configure
// multiple addresses to your DiscordID, and you cannot configure
// multiple DiscordIDs to your address. 1-1.

access(all) contract EmeraldIdentityLilico {

    //
    // Paths
    //
    access(all) let AdministratorStoragePath: StoragePath
    access(all) let AdministratorPrivatePath: PrivatePath

    //
    // Events
    //
    access(all) event EmeraldIDCreated(account: Address, discordID: String)
    access(all) event EmeraldIDRemoved(account: Address, discordID: String)
    
    //
    // Administrator
    //
    access(all) resource Administrator {
        // 1-to-1
        access(account) var accountToDiscord: {Address: String}
        // 1-to-1
        access(account) var discordToAccount: {String: Address}

        access(all) fun createEmeraldID(account: Address, discordID: String) {
            pre {
                EmeraldIdentityLilico.getAccountFromDiscord(discordID: discordID) == nil:
                    "The old discordID must remove their EmeraldID first."
                EmeraldIdentityLilico.getDiscordFromAccount(account: account) == nil: 
                    "The old account must remove their EmeraldID first."
            }

            self.accountToDiscord[account] = discordID
            self.discordToAccount[discordID] = account

            emit EmeraldIDCreated(account: account, discordID: discordID)
        }

        access(all) fun removeByAccount(account: Address) {
            let discordID = EmeraldIdentityLilico.getDiscordFromAccount(account: account) ?? panic("This EmeraldID does not exist!")
            self.remove(account: account, discordID: discordID)
        }

        access(all) fun removeByDiscord(discordID: String) {
            let account = EmeraldIdentityLilico.getAccountFromDiscord(discordID: discordID) ?? panic("This EmeraldID does not exist!")
            self.remove(account: account, discordID: discordID)
        }

        access(self) fun remove(account: Address, discordID: String) {
            self.discordToAccount.remove(key: discordID)
            self.accountToDiscord.remove(key: account)

            emit EmeraldIDRemoved(account: account, discordID: discordID)
        }

        // access(all) fun createAdministrator(): Capability<&Administrator> {
        //     return EmeraldIdentityLilico.account.getCapability<&Administrator>(EmeraldIdentityLilico.AdministratorPrivatePath)
        // }

        init() {
            self.accountToDiscord = {}
            self.discordToAccount = {}
        }
    }

    /*** USE THE BELOW FUNCTIONS FOR SECURE VERIFICATION OF ID ***/ 

    access(all) view fun getDiscordFromAccount(account: Address): String?  {
        let admin = EmeraldIdentityLilico.account.storage.borrow<&Administrator>(from: EmeraldIdentityLilico.AdministratorStoragePath)!
        return admin.accountToDiscord[account]
    }

    access(all) view fun getAccountFromDiscord(discordID: String): Address? {
        let admin = EmeraldIdentityLilico.account.storage.borrow<&Administrator>(from: EmeraldIdentityLilico.AdministratorStoragePath)!
        return admin.discordToAccount[discordID]
    }

    init() {
        self.AdministratorStoragePath = /storage/EmeraldIDLilicoAdministrator
        self.AdministratorPrivatePath = /private/EmeraldIDLilicoAdministrator

        self.account.storage.save(<- create Administrator(), to: EmeraldIdentityLilico.AdministratorStoragePath)
    }
}