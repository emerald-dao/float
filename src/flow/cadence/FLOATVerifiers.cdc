// MADE BY: Emerald City, Jacob Tucker

// This contract is probably the most confusing element of the FLOAT
// platform. Listed here is a bunch of Structs which all implement
// FLOAT.IVerifier. 

// This pattern allows us to define arbitrary "restrictions" or "verifiers"
// on our FLOAT Events. For example, Timelock is a verifier that makes sure
// the current time is within the start and end date that the FLOAT Event host
// specified when they created an event.  

// The cool part is all of these verifiers are totally optional, and are only
// passed in with the newly created event if the host wanted to enable them.  
// You can mix and match them however you want. For example, one event I could
// use both Timelock and Limited, and for another event I could just use Secret.  

// Each verifier must have a `verify` function that takes in a generalized `params`
// argument so we can pass user data through as well as info about the event itself.  
// This is important for Secret for example because we want to pass the users guess
// of the secret code through. For Limited, we need to know the totalSupply of the event,
// so we pass it through as well.

import FLOAT from "./FLOAT.cdc"
import FungibleToken from "./utility/FungibleToken.cdc"
import FlowToken from "./utility/FlowToken.cdc"
import Crypto

pub contract FLOATVerifiers {

    // The "verifiers" to be used
    
    //
    // Timelock
    //
    // Specifies a time range in which the 
    // FLOAT from an event can be claimed
    pub struct Timelock: FLOAT.IVerifier {
        // An automatic switch handled by the contract
        // to stop people from claiming after a certain time.
        pub let dateStart: UFix64
        pub let dateEnding: UFix64

        pub fun verify(_ params: {String: AnyStruct}) {
            assert(
                getCurrentBlock().timestamp >= self.dateStart,
                message: "This FLOAT Event has not started yet."
            )
            assert(
                getCurrentBlock().timestamp <= self.dateEnding,
                message: "Sorry! The time has run out to mint this FLOAT."
            )
        }

        init(_dateStart: UFix64, _timePeriod: UFix64) {
            self.dateStart = _dateStart
            self.dateEnding = self.dateStart + _timePeriod
        }
    }

    //
    // Secret
    //
    // Specifies a secret code in order
    // to claim a FLOAT (not very secure, but cool feature)
    pub struct Secret: FLOAT.IVerifier {
        // The secret code, set by the owner of this event.
        access(self) let secretPhrase: String

        pub fun verify(_ params: {String: AnyStruct}) {
            let secretPhrase = params["secretPhrase"]! as! String
            assert(
                self.secretPhrase == secretPhrase, 
                message: "You did not input the correct secret phrase."
            )
        }

        init(_secretPhrase: String) {
            self.secretPhrase = _secretPhrase
        }
    }

    //
    // Limited
    //
    // Specifies a limit for the amount of people
    // who can CLAIM. Not to be confused with how many currently
    // hold a FLOAT from this event, since users can
    // delete their FLOATs.
    pub struct Limited: FLOAT.IVerifier {
        pub var capacity: UInt64

        pub fun verify(_ params: {String: AnyStruct}) {
            let event = params["event"]! as! &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}
            let currentCapacity = event.totalSupply
            assert(
                currentCapacity < self.capacity,
                message: "This FLOAT Event is at capacity."
            )
        }

        init(_capacity: UInt64) {
            self.capacity = _capacity
        }
    }

    //
    // MultipleSecret
    //
    // Allows for Multiple Secret codes
    // Everytime a secret gets used, it gets removed
    // from the list.
    pub struct MultipleSecret: FLOAT.IVerifier {
        access(self) let secrets: {String: Bool}

        pub fun verify(_ params: {String: AnyStruct}) {
            let secretPhrase = params["secretPhrase"]! as! String
            assert(
                self.secrets[secretPhrase] != nil, 
                message: "You did not input a correct secret phrase."
            )
            self.secrets.remove(key: secretPhrase)
        }

        init(_secrets: [String]) {
            self.secrets = {}
            for secret in _secrets {
                self.secrets[secret] = true
            }
        }
    }

    //
    // SecretV2
    //
    // Much more secure than Secret
    pub struct SecretV2: FLOAT.IVerifier {
        pub let publicKey: String

        pub fun verify(_ params: {String: AnyStruct}) {
            let data: [UInt8] = (params["claimee"]! as! Address).toString().utf8
            let sig: [UInt8] = (params["secretSig"]! as! String).decodeHex()
            let publicKey = PublicKey(publicKey: self.publicKey.decodeHex(), signatureAlgorithm: SignatureAlgorithm.ECDSA_P256)
            // validates that the "sig" was what was produced by signing "data" using the private key paired to "publicKey"
            let valid = publicKey.verify(signature: sig, signedData: data, domainSeparationTag: "FLOW-V0.0-user", hashAlgorithm: HashAlgorithm.SHA3_256)
            
            assert(
                valid, 
                message: "You did not input the correct secret phrase."
            )
        }

        init(_publicKey: String) {
            self.publicKey = _publicKey
        }
    }

    //
    // MinimumBalance
    //
    // Requires a minimum Flow Balance to succeed
    pub struct MinimumBalance: FLOAT.IVerifier {
        pub let amount: UFix64

        pub fun verify(_ params: {String: AnyStruct}) {
            let claimee: Address = params["claimee"]! as! Address
            let flowVault = getAccount(claimee).getCapability(/public/flowTokenBalance)
                                .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
                                ?? panic("Could not borrow the Flow Token Vault")
            
            assert(
                flowVault.balance >= self.amount, 
                message: "You do not meet the minimum required Flow Token balance."
            )
        }

        init(_amount: UFix64) {
            self.amount = _amount
        }
    }

    //
    // Email
    //
    // Requires an admin to sign off that a user
    // address provided their email
    pub struct Email: FLOAT.IVerifier {
        pub let publicKey: String

        pub fun verify(_ params: {String: AnyStruct}) {
            let event = params["event"]! as! &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}
            let claimeeAddressAsString: String = (params["claimee"]! as! Address).toString()
            let messageString: String = claimeeAddressAsString.concat(" provided email for eventId ").concat(event.eventId.toString())
            let data: [UInt8] = messageString.utf8
            let sig: [UInt8] = (params["emailSig"]! as! String).decodeHex()
            let publicKey = PublicKey(publicKey: self.publicKey.decodeHex(), signatureAlgorithm: SignatureAlgorithm.ECDSA_P256)
            // validates that the "sig" was what was produced by signing "data" using the private key paired to "publicKey"
            let valid = publicKey.verify(signature: sig, signedData: data, domainSeparationTag: "FLOW-V0.0-user", hashAlgorithm: HashAlgorithm.SHA3_256)
            
            assert(
                valid, 
                message: "You did not input the correct secret phrase."
            )
        }

        init(_publicKey: String) {
            self.publicKey = _publicKey
        }
    }

    // From: ZayVerifierV2 contract: https://contractbrowser.com/A.4c577a03bc1a82e0.ZayVerifierV2
    //
    // Explanation:
    // Verifies that `acctAddress` is the one that signed the `message`, which contains `intent`,
    // producing `signatures` with the `keyIds` (that are hopefully in its account, or its false)
    // during `signatureBlock`
    // Parameters:
    // acctAddress: the address of the account we're verifying
    // message: {intent}{blockId}
    // keyIds: the keyIds that the acctAddress theoretically signed with
    // signatures: the signature that was theoretically produced from the `acctAddress` signing `message` with `keyIds`.
    // can be multiple because you can sign with multiple keys, thus creating multiple signatures.
    // signatureBlock: when the signature was produced
    //
    // Returns:
    // Whether or not this signature is valid
    pub fun verifySignature(acctAddress: Address, intent: String, message: String, keyIds: [Int], signatures: [String], signatureBlock: UInt64): Bool {
        let keyList = Crypto.KeyList()
        let account = getAccount(acctAddress)

        let publicKeys: [[UInt8]] = []
        let weights: [UFix64] = []
        let signAlgos: [UInt] = []

        let uniqueKeys: {Int: Bool} = {}
        for id in keyIds {
            uniqueKeys[id] = true
        }
        assert(uniqueKeys.keys.length == keyIds.length, message: "Invalid duplicates of the same keyID provided for signature")

        var counter = 0
        var totalWeight = 0.0
        while (counter < keyIds.length) {
            let accountKey: AccountKey = account.keys.get(keyIndex: keyIds[counter]) ?? panic("Provided key signature does not exist")

            publicKeys.append(accountKey.publicKey.publicKey)
            let keyWeight = accountKey.weight
            weights.append(keyWeight)
            totalWeight = totalWeight + keyWeight

            signAlgos.append(UInt(accountKey.publicKey.signatureAlgorithm.rawValue))

            counter = counter + 1
        }

        // Why 999 instead of 1000? Blocto currently signs with a 999 weight key sometimes for non-custodial blocto accounts.
        // We would like to support these non-custodial Blocto wallets - but can be switched to 1000 weight when Blocto updates this.
        assert(totalWeight >= 999.0, message: "Total weight of combined signatures did not satisfy 999 requirement.")

        var i = 0
        for publicKey in publicKeys {
            keyList.add(
                PublicKey(
                    publicKey: publicKey,
                    signatureAlgorithm: signAlgos[i] == 2 ? SignatureAlgorithm.ECDSA_secp256k1  : SignatureAlgorithm.ECDSA_P256
                ),
                hashAlgorithm: HashAlgorithm.SHA3_256,
                weight: weights[i]
            )
            i = i + 1
        }

        // In verify we need a [KeyListSignature] so we do that here
        let signatureSet: [Crypto.KeyListSignature] = []
        var j = 0
        for signature in signatures {
            signatureSet.append(
                Crypto.KeyListSignature(
                    keyIndex: keyIds[j],
                    signature: signature.decodeHex()
                )
            )
            j = j + 1
        }

        counter = 0
        let signingBlock = getBlock(at: signatureBlock)!
        let blockId = signingBlock.id
        let blockIds: [UInt8] = []
        while (counter < blockId.length) {
            blockIds.append(blockId[counter])
            counter = counter + 1
        }

        // message: {intent}{blockId}
        let intentHex = String.encodeHex(intent.utf8)
        let blockIdHexStr: String = String.encodeHex(blockIds)

        // Matches the intent
        assert(
            intentHex == message.slice(from: 0, upTo: intentHex.length),
            message: "Failed to validate intent"
        )
        // Ensure that the message passed in is of the current block id...
        assert(
            blockIdHexStr == message.slice(from: intentHex.length, upTo: message.length),
            message: "Unable to validate signature provided contained a valid block id."
        )

        let signatureValid = keyList.verify(
            signatureSet: signatureSet,
            signedData: message.decodeHex()
        )
        return signatureValid
    }
}