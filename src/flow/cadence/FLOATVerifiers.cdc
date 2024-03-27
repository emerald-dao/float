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

import "FLOAT"
import "FungibleToken"
import "FlowToken"
import Crypto
// import "FLOATEventSeries"

access(all) contract FLOATVerifiers {

    // The "verifiers" to be used
    
    //
    // Timelock
    //
    // Specifies a time range in which the 
    // FLOAT from an event can be claimed
    access(all) struct Timelock: FLOAT.IVerifier {
        // An automatic switch handled by the contract
        // to stop people from claiming after a certain time.
        access(all) let dateStart: UFix64
        access(all) let dateEnding: UFix64

        access(all) fun verify(_ params: {String: AnyStruct}) {
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
    access(all) struct Secret: FLOAT.IVerifier {
        // The secret code, set by the owner of this event.
        access(self) let secretPhrase: String

        access(all) fun verify(_ params: {String: AnyStruct}) {
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
    access(all) struct Limited: FLOAT.IVerifier {
        access(all) var capacity: UInt64

        access(all) fun verify(_ params: {String: AnyStruct}) {
            let floatEvent = params["event"]! as! &FLOAT.FLOATEvent
            let currentCapacity = floatEvent.totalSupply
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
    access(all) struct MultipleSecret: FLOAT.IVerifier {
        access(self) let secrets: {String: Bool}

        access(all) fun verify(_ params: {String: AnyStruct}) {
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
    access(all) struct SecretV2: FLOAT.IVerifier {
        access(all) let publicKey: String

        access(all) fun verify(_ params: {String: AnyStruct}) {
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
    access(all) struct MinimumBalance: FLOAT.IVerifier {
        access(all) let amount: UFix64

        access(all) fun verify(_ params: {String: AnyStruct}) {
            let claimee: Address = params["claimee"]! as! Address
            let flowVault = getAccount(claimee).capabilities.borrow<&FlowToken.Vault>(/public/flowTokenBalance)
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
    // ChallengeAchievementPoint
    // 
    // Specifies a FLOAT Challenge to limit who accomplished 
    // a number of achievement point can claim the FLOAT
    // access(all) struct ChallengeAchievementPoint: FLOAT.IVerifier {
    //     access(all) let challengeIdentifier: FLOATEventSeries.EventSeriesIdentifier
    //     access(all) let challengeThresholdPoints: UInt64

    //     access(all) fun verify(_ params: {String: AnyStruct}) {
    //         let claimee: Address = params["claimee"]! as! Address
    //         if let achievementBoard = getAccount(claimee)
    //             .getCapability(FLOATEventSeries.FLOATAchievementBoardPublicPath)
    //             .borrow<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>()
    //         {
    //             // build goal status by different ways
    //             if let record = achievementBoard.borrowAchievementRecordRef(
    //                 host: self.challengeIdentifier.host,
    //                 seriesId: self.challengeIdentifier.id
    //             ) {
    //                 assert(
    //                     record.score >= self.challengeThresholdPoints,
    //                     message: "You do not meet the minimum required Achievement Point for Challenge#".concat(self.challengeIdentifier.id.toString())
    //                 )
    //             } else {
    //                 panic("You do not have Challenge Achievement Record for Challenge#".concat(self.challengeIdentifier.id.toString()))
    //             }
    //         } else {
    //             panic("You do not have Challenge Achievement Board")
    //         }
    //     }

    //     init(_challengeHost: Address, _challengeId: UInt64, thresholdPoints: UInt64) {
    //         self.challengeThresholdPoints = thresholdPoints
    //         self.challengeIdentifier = FLOATEventSeries.EventSeriesIdentifier(_challengeHost, _challengeId)
    //         // ensure challenge exists
    //         self.challengeIdentifier.getEventSeriesPublic()
    //     }
    // }

    //
    // Email
    //
    // Requires an admin to sign off that a user
    // address provided their email
    access(all) struct Email: FLOAT.IVerifier {
        access(all) let publicKey: String

        access(all) fun verify(_ params: {String: AnyStruct}) {
            let floatEvent = params["event"]! as! &FLOAT.FLOATEvent
            let claimeeAddressAsString: String = (params["claimee"]! as! Address).toString()
            let messageString: String = claimeeAddressAsString.concat(" provided email for eventId ").concat(floatEvent.eventId.toString())
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
    
}