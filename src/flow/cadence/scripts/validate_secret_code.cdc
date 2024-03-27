import "FLOAT"
import "FLOATVerifiers"

access(all) fun main(eventId: UInt64, host: Address, secretSig: String, claimee: Address): Bool {
    let floatEventCollection = getAccount(host).capabilities.borrow<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsPublicPath)
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
    let FLOATEvent: &FLOAT.FLOATEvent = floatEventCollection.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist.")

    let secretVerifier: FLOATVerifiers.SecretV2 = FLOATEvent.getVerifiers()["${verifiersIdentifier}.FLOATVerifiers.SecretV2"]![0] as! FLOATVerifiers.SecretV2

    let data: [UInt8] = claimee.toString().utf8
    let sig: [UInt8] = secretSig.decodeHex()
    let publicKey: PublicKey = PublicKey(publicKey: secretVerifier.publicKey.decodeHex(), signatureAlgorithm: SignatureAlgorithm.ECDSA_P256)
    let valid: Bool = publicKey.verify(signature: sig, signedData: data, domainSeparationTag: "FLOW-V0.0-user", hashAlgorithm: HashAlgorithm.SHA3_256)

    return valid
}