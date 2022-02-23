import { browser } from '$app/env';

import * as fcl from "@samatech/onflow-fcl-esm";

import "./config.js";
import {
  user,
  txId,
  transactionStatus,
  transactionInProgress,
  eventCreationInProgress,
  eventCreatedStatus,
  floatClaimingInProgress,
  floatClaimedStatus,
  addSharedMinterInProgress,
  removeSharedMinterInProgress
} from './stores.js';

import { draftFloat } from '$lib/stores';
import { respondWithError, respondWithSuccess } from '$lib/response';
import { parseErrorMessageFromFCL } from './utils.js';

if (browser) {
  // set Svelte $user store to currentUser, 
  // so other components can access it
  fcl.currentUser.subscribe(user.set, [])
}

// Lifecycle FCL Auth functions
export const unauthenticate = () => fcl.unauthenticate();
export const authenticate = () => fcl.authenticate();

const convertDraftFloat = (draftFloat) => {
  let secrets = []
  if (draftFloat.multipleSecretsEnabled) {
    secrets = draftFloat.claimCode.split(', ');
  } else {
    secrets = [draftFloat.claimCode];
  }
  return {
    claimable: draftFloat.claimable,
    name: draftFloat.name,
    description: draftFloat.description,
    image: draftFloat.ipfsHash,
    url: draftFloat.url,
    transferrable: draftFloat.transferrable,
    timelock: draftFloat.timelock,
    dateStart: +new Date(draftFloat.startTime) / 1000,
    timePeriod: (+new Date(draftFloat.endTime) / 1000) - (+new Date(draftFloat.startTime) / 1000),
    secret: draftFloat.claimCodeEnabled,
    secrets: secrets,
    limited: draftFloat.quantity ? true : false,
    capacity: draftFloat.quantity ? draftFloat.quantity : 0,
  };
}

/****************************** SETTERS ******************************/

export const createFloat = async (draftFloat) => {

  let floatObject = convertDraftFloat(draftFloat);

  eventCreationInProgress.set(true);

  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE
      import FLOATVerifiers from 0xFLOAT

      transaction(claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secrets: [String], limited: Bool, capacity: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
          // set up the FLOAT Collection where users will store their FLOATs
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // set up the FLOAT Events where users will store all their created events
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, FLOAT.FLOATEventsSharedMinter}>(FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }
      
          self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
        }
      
        execute {
          let verifier = FLOATVerifiers.Verifier(_timelock: timelock, _dateStart: dateStart, _timePeriod: timePeriod, _limited: limited, _capacity: capacity, _secret: secret, _secrets: secrets)
          self.FLOATEvents.createEvent(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifier: verifier, {})
          log("Started a new event.")
        }
      }      
      `,
      args: (arg, t) => [
        arg(floatObject.claimable, t.Bool),
        arg(floatObject.name, t.String),
        arg(floatObject.description, t.String),
        arg(floatObject.image, t.String),
        arg(floatObject.url, t.String),
        arg(floatObject.transferrable, t.Bool),
        arg(floatObject.timelock, t.Bool),
        arg(floatObject.dateStart.toFixed(1), t.UFix64),
        arg(floatObject.timePeriod.toFixed(1), t.UFix64),
        arg(floatObject.secret, t.Bool),
        arg(floatObject.secrets, t.Array(t.String)),
        arg(floatObject.limited, t.Bool),
        arg(floatObject.capacity, t.UInt64),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        if (res.statusCode === 0) {
          eventCreatedStatus.set(respondWithSuccess());
        } else {
          eventCreatedStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        eventCreationInProgress.set(false);
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    eventCreatedStatus.set(false);
    transactionStatus.set(99)
    console.log(e)

    setTimeout(() => transactionInProgress.set(false), 10000)
  }
}

export const createFloatForHost = async (forHost, draftFloat) => {

  let floatObject = convertDraftFloat(draftFloat);

  eventCreationInProgress.set(true);

  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import FLOATVerifiers from 0xFLOAT

      transaction(forHost: Address, claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secrets: [String], limited: Bool, capacity: UInt64) {

        let SharedMinter: &FLOAT.FLOATEvents

        prepare(acct: AuthAccount) {
          let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          self.SharedMinter = FLOATEvents.getSharedMinterRef(host: forHost) 
                                ?? panic("You do not have access to this host's minting rights.")
        }

        execute {
          let verifier = FLOATVerifiers.Verifier(_timelock: timelock, _dateStart: dateStart, _timePeriod: timePeriod, _limited: limited, _capacity: capacity, _secret: secret, _secrets: secrets)
          self.SharedMinter.createEvent(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifier: verifier, {})
          log("Started a new event for host.")
        }
      }  
      `,
      args: (arg, t) => [
        arg(forHost, t.Address),
        arg(floatObject.claimable, t.Bool),
        arg(floatObject.name, t.String),
        arg(floatObject.description, t.String),
        arg(floatObject.image, t.String),
        arg(floatObject.url, t.String),
        arg(floatObject.transferrable, t.Bool),
        arg(floatObject.timelock, t.Bool),
        arg(floatObject.dateStart.toFixed(1), t.UFix64),
        arg(floatObject.timePeriod.toFixed(1), t.UFix64),
        arg(floatObject.secret, t.Bool),
        arg(floatObject.secrets, t.Array(t.String)),
        arg(floatObject.limited, t.Bool),
        arg(floatObject.capacity, t.UInt64),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        if (res.statusCode === 0) {
          eventCreatedStatus.set(respondWithSuccess());
        } else {
          eventCreatedStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        eventCreationInProgress.set(false);
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    eventCreatedStatus.set(false);
    transactionStatus.set(99)
    console.log(e)

    setTimeout(() => transactionInProgress.set(false), 10000)
  }
}

export const claimFLOAT = async (eventId, host, secret) => {

  let transactionId = false;
  initTransactionState()

  floatClaimingInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE

      transaction(eventId: UInt64, host: Address, secret: String?) {
      
        let FLOATEvent: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}
        let Collection: &FLOAT.Collection

        prepare(acct: AuthAccount) {
          // set up the FLOAT Collection where users will store their FLOATs
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }

          // set up the FLOAT Events where users will store all their created events
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, FLOAT.FLOATEventsSharedMinter}>(FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }

          let FLOATEvents = getAccount(host).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the public FLOATEvents from the host.")
          self.FLOATEvent = FLOATEvents.borrowPublicEventRef(eventId: eventId)

          self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                              ?? panic("Could not get the Collection from the signer.")
        }

        execute {
          let params: {String: AnyStruct} = {}
          if let unwrappedSecret = secret {
            params["secretPhrase"] = unwrappedSecret
          }
          self.FLOATEvent.claim(recipient: self.Collection, params: params)
          log("Claimed the FLOAT.")
        }
      }
      
      `,
      args: (arg, t) => [
        arg(parseInt(eventId), t.UInt64),
        arg(host, t.Address),
        arg(secret, t.Optional(t.String)),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        console.log(res);
        if (res.statusCode === 0) {
          floatClaimedStatus.set(respondWithSuccess());
        } else {
          floatClaimedStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        floatClaimingInProgress.set(false);
        draftFloat.set({
          claimable: true,
          transferrable: true,
        })

        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99)
    floatClaimedStatus.set(respondWithError(e));
    floatClaimingInProgress.set(false);

    console.log(e)
  }
}

export const deleteFLOAT = async (id) => {

  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(id: UInt64) {

        let Collection: &FLOAT.Collection
      
        prepare(acct: AuthAccount) {
          self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                              ?? panic("Could not get the Collection from the signer.")
        }
      
        execute {
          self.Collection.destroyFLOAT(id: id)
          log("Destroyed the FLOAT.")
        }
      }
      `,
      args: (arg, t) => [
        arg(id, t.UInt64)
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        draftFloat.set({
          claimable: true,
          transferrable: true,
        })

        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99)

    console.log(e)
  }
}

export const transferFLOAT = async (id, recipient) => {

  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE

      transaction(id: UInt64, recipient: Address) {

        let Collection: &FLOAT.Collection
        let RecipientCollection: &FLOAT.Collection{NonFungibleToken.CollectionPublic}

        prepare(acct: AuthAccount) {
          self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                              ?? panic("Could not get the Collection from the signer.")
          self.RecipientCollection = getAccount(recipient).getCapability(FLOAT.FLOATCollectionPublicPath)
                                    .borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>()
                                    ?? panic("Could not borrow the recipient's public FLOAT Collection.")
        }

        execute {
          self.Collection.transfer(withdrawID: id, recipient: self.RecipientCollection)
          log("Transferred the FLOAT.")
        }
      }
      `,
      args: (arg, t) => [
        arg(id, t.UInt64),
        arg(recipient, t.Address)
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        draftFloat.set({
          claimable: true,
          transferrable: true,
        })

        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99)

    console.log(e)
  }
}

export const toggleClaimable = async (eventId) => {
  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(eventId: UInt64) {

        let FLOATEvent: &FLOAT.FLOATEvent
      
        prepare(acct: AuthAccount) {
          let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          self.FLOATEvent = FLOATEvents.borrowEventRef(eventId: eventId)
        }
      
        execute {
          self.FLOATEvent.toggleClaimable()
          log("Toggled the FLOAT Event.")
        }
      }
      `,
      args: (arg, t) => [
        arg(eventId, t.UInt64),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99)
    console.log(e)
  }
}

export const toggleTransferrable = async (eventId) => {
  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(eventId: UInt64) {

        let FLOATEvent: &FLOAT.FLOATEvent
      
        prepare(acct: AuthAccount) {
          let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          self.FLOATEvent = FLOATEvents.borrowEventRef(eventId: eventId)
        }
      
        execute {
          self.FLOATEvent.toggleTransferrable()
          log("Toggled the FLOAT Event.")
        }
      }
      `,
      args: (arg, t) => [
        arg(eventId, t.UInt64),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99)
    console.log(e)
  }
}

export const deleteEvent = async (eventId) => {
  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
          self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
        }
      
        execute {
          self.FLOATEvents.deleteEvent(eventId: eventId)
          log("Removed the FLOAT Event.")
        }
      }
      `,
      args: (arg, t) => [
        arg(eventId, t.UInt64),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99)
    console.log(e)
  }
}

export const addSharedMinter = async (receiver) => {
  let transactionId = false;
  initTransactionState();

  addSharedMinterInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE

      transaction (receiver: Address) {

        let ReceiverFLOATEvents: &FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}
        let GiverFLOATEvents: &FLOAT.FLOATEvents
        
        prepare(acct: AuthAccount) {
          // set up the FLOAT Collection where users will store their FLOATs
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // set up the FLOAT Events where users will store all their created events
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, FLOAT.FLOATEventsSharedMinter}>(FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }
      
          self.ReceiverFLOATEvents = getAccount(receiver).getCapability(FLOAT.FLOATEventsPublicPath)
                                      .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>() 
                                      ?? panic("This Capability does not exist")
          self.GiverFLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                                    ?? panic("The signer does not have a FLOAT Events.")
        }
      
        execute {
          self.GiverFLOATEvents.giveSharing(toHost: self.ReceiverFLOATEvents)
          log("The Receiver now has access to the signer's FLOATEvents.")
        }
      }
      `,
      args: (arg, t) => [
        arg(receiver, t.Address),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        setTimeout(() => transactionInProgress.set(false), 2000)
        addSharedMinterInProgress.set(false);
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99)
    console.log(e)
  }
}

export const removeSharedMinter = async (withHost) => {
  let transactionId = false;
  initTransactionState();
  console.log(withHost);

  removeSharedMinterInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction (fromHost: Address) {

        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
          self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                                    ?? panic("The signer does not have a FLOAT Events.")
        }
      
        execute {
          self.FLOATEvents.takeSharing(fromHost: fromHost)
          log("Removes sharing withHost.")
        }
      }      
      `,
      args: (arg, t) => [
        arg(withHost, t.Address),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        setTimeout(() => transactionInProgress.set(false), 2000)
        removeSharedMinterInProgress.set(false);
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99)
    console.log(e)
  }
}


/****************************** GETTERS ******************************/

export const getEvent = async (addr, eventId) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import FLOATVerifiers from 0xFLOAT

      pub fun main(account: Address, eventId: UInt64): FLOATEventMetadataView {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let event = floatEventCollection.borrowPublicEventRef(eventId: eventId)
        return FLOATEventMetadataView(
          _canAttemptClaim: event.verifier.canAttemptClaim(event: event), 
          _claimable: event.claimable, 
          _dateCreated: event.dateCreated, 
          _description: event.description, 
          _extraMetadata: event.getExtraMetadata(), 
          _host: event.host, 
          _eventId: event.eventId, 
          _image: event.image, 
          _name: event.name, 
          _requiresSecret: event.verifier.activatedModules().contains(Type<FLOATVerifiers.Secret>()) || event.verifier.activatedModules().contains(FLOATVerifiers.MultipleSecret.getType()), 
          _totalSupply: event.totalSupply, 
          _transferrable: event.transferrable, 
          _url: event.url, 
          _verifier: event.verifier
        )
      }

      pub struct FLOATEventMetadataView {
          pub let canAttemptClaim: Bool
          pub let claimable: Bool
          pub let dateCreated: UFix64
          pub let description: String 
          pub let extraMetadata: {String: String}
          pub let host: Address
          pub let eventId: UInt64
          pub let image: String 
          pub let name: String
          pub let requiresSecret: Bool
          pub var totalSupply: UInt64
          pub let transferrable: Bool
          pub let url: String
          pub let verifier: {FLOAT.IVerifier}

          init(
              _canAttemptClaim: Bool,
              _claimable: Bool,
              _dateCreated: UFix64,
              _description: String, 
              _extraMetadata: {String: String},
              _host: Address, 
              _eventId: UInt64,
              _image: String, 
              _name: String,
              _requiresSecret: Bool,
              _totalSupply: UInt64,
              _transferrable: Bool,
              _url: String,
              _verifier: {FLOAT.IVerifier}
          ) {
              self.canAttemptClaim = _canAttemptClaim
              self.claimable = _claimable
              self.dateCreated = _dateCreated
              self.description = _description
              self.extraMetadata = _extraMetadata
              self.host = _host
              self.eventId = _eventId
              self.image = _image
              self.name = _name
              self.requiresSecret = _requiresSecret
              self.totalSupply = _totalSupply
              self.transferrable = _transferrable
              self.url = _url
              self.verifier = _verifier
          }
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address),
        arg(parseInt(eventId), t.UInt64)
      ]
    })
    // console.log(queryResult);
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

export const getEvents = async (addr) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(account: Address): {String: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}} {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let floatEvents: [UInt64] = floatEventCollection.getIDs()
        let returnVal: {String: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}} = {}
      
        for eventId in floatEvents {
          let event = floatEventCollection.borrowPublicEventRef(eventId: eventId)
          returnVal[event.name] = event
        }
        return returnVal
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address)
      ]
    })
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

export const getFLOATs = async (addr) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(account: Address): [FLOATMetadataView] {
        let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                              .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                              ?? panic("Could not borrow the Collection from the account.")
        let floats = floatCollection.getIDs()
        var returnVal: [FLOATMetadataView] = []
        for id in floats {
          let float = floatCollection.borrowFLOAT(id: id)
          let event = float.getEventMetadata()
          let floatMetadata = FLOATMetadataView(
            _id: float.id, 
            _dateReceived: float.dateReceived, 
            _eventId: float.eventId, 
            _eventHost: float.eventHost, 
            _originalRecipient: float.originalRecipient, 
            _owner: account, 
            _serial: float.serial,
            _eventMetadata: FLOATEventMetadataView(
              _dateCreated: event.dateCreated, 
              _description: event.description, 
              _host: event.host, 
              _eventId: event.eventId, 
              _image: event.image, 
              _name: event.name, 
              _url: event.url
            )
          )
          returnVal.append(floatMetadata)
        }
      
        return returnVal
      }
      
      pub struct FLOATMetadataView {
        pub let id: UInt64
        pub let dateReceived: UFix64
        pub let eventId: UInt64
        pub let eventHost: Address
        pub let originalRecipient: Address
        pub let owner: Address
        pub let serial: UInt64
        pub let eventMetadata: FLOATEventMetadataView
      
        init(
            _id: UInt64,
            _dateReceived: UFix64, 
            _eventId: UInt64,
            _eventHost: Address, 
            _originalRecipient: Address, 
            _owner: Address,
            _serial: UInt64,
            _eventMetadata: FLOATEventMetadataView
        ) {
            self.id = _id
            self.dateReceived = _dateReceived
            self.eventId = _eventId
            self.eventHost = _eventHost
            self.originalRecipient = _originalRecipient
            self.owner = _owner
            self.serial = _serial
            self.eventMetadata = _eventMetadata
        }
      }
      
      pub struct FLOATEventMetadataView {
          pub let dateCreated: UFix64
          pub let description: String
          pub let host: Address
          pub let eventId: UInt64
          pub let image: String 
          pub let name: String
          pub let url: String
      
          init(
              _dateCreated: UFix64,
              _description: String, 
              _host: Address, 
              _eventId: UInt64,
              _image: String, 
              _name: String,
              _url: String,
          ) {
              self.dateCreated = _dateCreated
              self.description = _description
              self.host = _host
              self.eventId = _eventId
              self.image = _image
              self.name = _name
              self.url = _url
          }
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address)
      ]
    })
    // console.log(queryResult);
    return queryResult || [];
  } catch (e) {
    console.log(e);
  }
}

export const getFLOAT = async (addr, id) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(account: Address, id: UInt64): FLOATMetadataView {
        let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                              .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                              ?? panic("Could not borrow the Collection from the account.")
        let float = floatCollection.borrowFLOAT(id: id)
        return FLOATMetadataView(
          _id: float.id, 
          _dateReceived: float.dateReceived, 
          _eventId: float.eventId, 
          _eventHost: float.eventHost, 
          _originalRecipient: float.originalRecipient, 
          _owner: account, 
          _serial: float.serial
        )
      }

      pub struct FLOATMetadataView {
          pub let id: UInt64
          pub let dateReceived: UFix64
          pub let eventId: UInt64
          pub let eventHost: Address
          pub let originalRecipient: Address
          pub let owner: Address
          pub let serial: UInt64

          init(
              _id: UInt64,
              _dateReceived: UFix64, 
              _eventId: UInt64,
              _eventHost: Address, 
              _originalRecipient: Address, 
              _owner: Address,
              _serial: UInt64,
          ) {
              self.id = _id
              self.dateReceived = _dateReceived
              self.eventId = _eventId
              self.eventHost = _eventHost
              self.originalRecipient = _originalRecipient
              self.owner = _owner
              self.serial = _serial
          }
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address),
        arg(id, t.UInt64)
      ]
    })
    // console.log(queryResult)
    return queryResult || [];
  } catch (e) {
    console.log(e);
  }
}

export const getHoldersInEvent = async (addr, eventId) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import FLOATMetadataViews from 0xFLOAT

      pub fun main(account: Address, eventId: UInt64): {UInt64: FLOATMetadataViews.TokenIdentifier} {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        return floatEventCollection.borrowPublicEventRef(eventId: eventId).getCurrentHolders()
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address),
        arg(parseInt(eventId), t.UInt64)
      ]
    })
    // console.log(queryResult);
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

export const getClaimedInEvent = async (addr, eventId) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import FLOATMetadataViews from 0xFLOAT

      pub fun main(account: Address, eventId: UInt64): {Address: FLOATMetadataViews.TokenIdentifier} {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        return floatEventCollection.borrowPublicEventRef(eventId: eventId).getClaimed()
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address),
        arg(parseInt(eventId), t.UInt64)
      ]
    })
    // console.log(queryResult);
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

export const hasClaimedEvent = async (hostAddress, eventId, accountAddress) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import FLOATMetadataViews from 0xFLOAT

      pub fun main(hostAddress: Address, eventId: UInt64, accountAddress: Address): FLOATMetadataViews.TokenIdentifier? {
        let floatEventCollection = getAccount(hostAddress).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let floatEventPublic = floatEventCollection.borrowPublicEventRef(eventId: eventId)
      
        return floatEventPublic.hasClaimed(account: accountAddress)
      }
      `,
      args: (arg, t) => [
        arg(hostAddress, t.Address),
        arg(parseInt(eventId), t.UInt64),
        arg(accountAddress, t.Address)
      ]
    })
    
    return queryResult || queryResult === false;
  } catch (e) {
    console.log(e);
  }
}

export const getCurrentHolder = async (hostAddress, eventId, serial) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import FLOATMetadataViews from 0xFLOAT

      pub fun main(hostAddress: Address, eventId: UInt64, serial: UInt64): FLOATMetadataViews.TokenIdentifier? {
        let floatEventCollection = getAccount(hostAddress).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let floatEventPublic = floatEventCollection.borrowPublicEventRef(eventId: eventId)
      
        return floatEventPublic.getCurrentHolder(serial: serial)
      }
      `,
      args: (arg, t) => [
        arg(hostAddress, t.Address),
        arg(parseInt(eventId), t.UInt64),
        arg(parseInt(serial), t.UInt64)
      ]
    })
    // console.log(queryResult);
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

export const getAddressesWhoICanMintFor = async (address) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(address: Address): [Address] {
        let floatEventCollection = getAccount(address).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        return floatEventCollection.getAddressWhoICanMintFor()
      }
      `,
      args: (arg, t) => [
        arg(address, t.Address)
      ]
    })
    // console.log(queryResult);
    return queryResult || [];
  } catch (e) {
    console.log(e);
  }
}

export const getAddressesWhoCanMintForMe = async (address) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(address: Address): [Address] {
        let floatEventCollection = getAccount(address).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        return floatEventCollection.getAddressWhoCanMintForMe()
      }
      `,
      args: (arg, t) => [
        arg(address, t.Address)
      ]
    })
    // console.log(queryResult);
    return queryResult || [];
  } catch (e) {
    console.log(e);
  }
}

export const resolveVerifier = async (address, eventId) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import FLOATVerifiers from 0xFLOAT

      pub fun main(account: Address, eventId: UInt64): {String: AnyStruct} {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let publicRef: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic} = floatEventCollection.borrowPublicEventRef(eventId: eventId)
        let verifier = publicRef.verifier as! FLOATVerifiers.Verifier
        let answers: {String: AnyStruct} = {}
      
        if let timelock = verifier.timelock {
          answers["dateStart"] = timelock.dateStart
          answers["dateEnding"] = timelock.dateEnding
        }
      
        if let limited = verifier.limited {
          answers["capacity"] = limited.capacity
        }
        return answers
      }
      `,
      args: (arg, t) => [
        arg(address, t.Address),
        arg(parseInt(eventId), t.UInt64)
      ]
    })
    // console.log(queryResult);
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

function initTransactionState() {
  transactionInProgress.set(true);
  transactionStatus.set(-1);
  floatClaimedStatus.set(false);
  eventCreatedStatus.set(false);
}