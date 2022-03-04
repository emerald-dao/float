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
  removeSharedMinterInProgress,
  floatDistributingInProgress,
  floatDistributingStatus,
  addSharedMinterStatus,
  toggleTransferringInProgress,
  toggleClaimingInProgress
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

export const createEvent = async (forHost, draftFloat) => {

  let floatObject = convertDraftFloat(draftFloat);

  eventCreationInProgress.set(true);

  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import FLOATVerifiers from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE
      import SharedAccount from 0xFLOAT

      transaction(forHost: Address?, claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secrets: [String], limited: Bool, capacity: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
          // set up the FLOAT Collection where users will store their FLOATs
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // set up the FLOAT Events where users will store all their created events
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }

          if acct.borrow<&SharedAccount.Info>(from: SharedAccount.InfoStoragePath) == nil {
            acct.save(<- SharedAccount.createInfo(), to: SharedAccount.InfoStoragePath)
            acct.link<&SharedAccount.Info{SharedAccount.InfoPublic}>
                    (SharedAccount.InfoPublicPath, target: SharedAccount.InfoStoragePath)
          }
          
          if let fromHost = forHost {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
        }
      
        execute {
          var Timelock: FLOATVerifiers.Timelock? = nil
          var Secret: FLOATVerifiers.Secret? = nil
          var Limited: FLOATVerifiers.Limited? = nil
          var MultipleSecret: FLOATVerifiers.MultipleSecret? = nil
          var verifiers: [{FLOAT.IVerifier}] = []
          if timelock {
            Timelock = FLOATVerifiers.Timelock(_dateStart: dateStart, _timePeriod: timePeriod)
            verifiers.append(Timelock!)
          }
          if secret {
            if secrets.length == 1 {
              Secret = FLOATVerifiers.Secret(_secretPhrase: secrets[0])
              verifiers.append(Secret!)
            } else {
              MultipleSecret = FLOATVerifiers.MultipleSecret(_secrets: secrets)
              verifiers.append(MultipleSecret!)
            }
          }
          if limited {
            Limited = FLOATVerifiers.Limited(_capacity: capacity)
            verifiers.append(Limited!)
          }
          self.FLOATEvents.createEvent(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifiers: verifiers, {})
          log("Started a new event for host.")
        }
      }  
      `,
      args: (arg, t) => [
        arg(forHost, t.Optional(t.Address)),
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
      import SharedAccount from 0xFLOAT

      transaction(eventId: UInt64, host: Address, secret: String?) {
 
        let FLOATEvent: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}
        let Collection: &FLOAT.Collection
      
        prepare(acct: AuthAccount) {
          // set up the FLOAT Collection where users will store their FLOATs
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // set up the FLOAT Events where users will store all their created events
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }

          if acct.borrow<&SharedAccount.Info>(from: SharedAccount.InfoStoragePath) == nil {
            acct.save(<- SharedAccount.createInfo(), to: SharedAccount.InfoStoragePath)
            acct.link<&SharedAccount.Info{SharedAccount.InfoPublic}>
                    (SharedAccount.InfoPublicPath, target: SharedAccount.InfoStoragePath)
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

export const distributeDirectly = async (forHost, eventId, recipient) => {

  let transactionId = false;
  initTransactionState()

  floatDistributingInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE

      transaction(forHost: Address?, eventId: UInt64, recipient: Address) {

        let FLOATEvents: &FLOAT.FLOATEvents
        let FLOATEvent: &FLOAT.FLOATEvent
        let RecipientCollection: &FLOAT.Collection{NonFungibleToken.CollectionPublic}
      
        prepare(acct: AuthAccount) {
          // set up the FLOAT Collection where users will store their FLOATs
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // set up the FLOAT Events where users will store all their created events
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }
      
          if let fromHost = forHost {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
      
          self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId)
          self.RecipientCollection = getAccount(recipient).getCapability(FLOAT.FLOATCollectionPublicPath)
                                      .borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>()
                                      ?? panic("Could not get the public FLOAT Collection from the recipient.")
        }
      
        execute {
          //
          // Give the "recipient" a FLOAT from the event with "id"
          //
      
          self.FLOATEvent.mint(recipient: self.RecipientCollection)
          log("Distributed the FLOAT.")
      
          //
          // SOME OTHER ACTION HAPPENS
          //
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Optional(t.Address)),
        arg(parseInt(eventId), t.UInt64),
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
        console.log(res);
        if (res.statusCode === 0) {
          floatDistributingStatus.set(respondWithSuccess());
        } else {
          floatDistributingStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        floatDistributingInProgress.set(false);

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

export const toggleClaimable = async (forHost, eventId) => {
  let transactionId = false;
  initTransactionState();
  toggleClaimingInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(forHost: Address?, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
        let FLOATEvent: &FLOAT.FLOATEvent
      
        prepare(acct: AuthAccount) {
          if let fromHost = forHost {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
      
          self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId)
        }
      
        execute {
          self.FLOATEvent.toggleClaimable()
          log("Toggled the FLOAT Event.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Optional(t.Address)),
        arg(eventId, t.UInt64)
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
        toggleClaimingInProgress.set(false);
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99)
    toggleClaimingInProgress.set(false);
    console.log(e)
  }
}

export const toggleTransferrable = async (forHost, eventId) => {
  let transactionId = false;
  initTransactionState();
  toggleTransferringInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(forHost: Address?, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
        let FLOATEvent: &FLOAT.FLOATEvent
      
        prepare(acct: AuthAccount) {
          if let fromHost = forHost {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
      
          self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId)
        }
      
        execute {
          self.FLOATEvent.toggleTransferrable()
          log("Toggled the FLOAT Event.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Optional(t.Address)),
        arg(eventId, t.UInt64)
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
        toggleTransferringInProgress.set(false);
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99)
    toggleTransferringInProgress.set(false);
    console.log(e)
  }
}

export const deleteEvent = async (forHost, eventId) => {
  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE

      transaction(forHost: Address?, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
          // set up the FLOAT Collection where users will store their FLOATs
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // set up the FLOAT Events where users will store all their created events
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          } 
      
          if let fromHost = forHost {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
        }
      
        execute {
          self.FLOATEvents.deleteEvent(eventId: eventId)
          log("Removed the FLOAT Event.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Optional(t.Address)),
        arg(eventId, t.UInt64)
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
      import SharedAccount from 0xFLOAT

      transaction (receiver: Address) {

        let Info: &SharedAccount.Info
        
        prepare(acct: AuthAccount) {
          // set up the FLOAT Collection where users will store their FLOATs
          if acct.borrow<&SharedAccount.Info>(from: SharedAccount.InfoStoragePath) == nil {
              acct.save(<- SharedAccount.createInfo(), to: SharedAccount.InfoStoragePath)
              acct.link<&SharedAccount.Info{SharedAccount.InfoPublic}>
                      (SharedAccount.InfoPublicPath, target: SharedAccount.InfoStoragePath)
          }

          self.Info = acct.borrow<&SharedAccount.Info>(from: SharedAccount.InfoStoragePath)!
        }

        execute {
          self.Info.addAccount(account: receiver)
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
        if (res.statusCode === 0) {
          addSharedMinterStatus.set(respondWithSuccess());
        }
        setTimeout(() => transactionInProgress.set(false), 2000)
        addSharedMinterInProgress.set(false);
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99)
    addSharedMinterStatus.set(respondWithError(parseErrorMessageFromFCL(e)));
    addSharedMinterInProgress.set(false);
    console.log(e)
  }
}

export const removeSharedMinter = async (user) => {
  let transactionId = false;
  initTransactionState();

  removeSharedMinterInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import SharedAccount from 0xFLOAT

      transaction(user: Address) {

        let Info: &SharedAccount.Info
      
        prepare(acct: AuthAccount) {
          self.Info = acct.borrow<&SharedAccount.Info>(from: SharedAccount.InfoStoragePath)
                        ?? panic("Could not borrow the Info from the signer.")
        }
      
        execute {
          self.Info.removeAccount(account: user)
        }
      }
      
      `,
      args: (arg, t) => [
        arg(user, t.Address),
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
    removeSharedMinterInProgress.set(false);
    console.log(e)
  }
}

export const createGroup = async (forHost, draftGroup) => {
  let transactionId = false;
  initTransactionState();

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(forHost: Address?, groupName: String, image: String, description: String) {

        let FLOATEvents: &FLOAT.FLOATEvents

        prepare(acct: AuthAccount) {
          if let fromHost = forHost {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
        }

        execute {
          self.FLOATEvents.createGroup(groupName: groupName, image: image, description: description)
          log("Created a new Group.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Optional(t.Address)),
        arg(draftGroup.name, t.String),
        arg(draftGroup.ipfsHash, t.String),
        arg(draftGroup.description, t.String)
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

export const deleteGroup = async (forHost, groupName) => {
  let transactionId = false;
  initTransactionState();

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(forHost: Address?, groupName: String) {

        let FLOATEvents: &FLOAT.FLOATEvents

        prepare(acct: AuthAccount) {
          if let fromHost = forHost {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
        }

        execute {
          self.FLOATEvents.deleteGroup(groupName: groupName)
          log("Deleted a Group.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Optional(t.Address)),
        arg(groupName, t.String)
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

export const addEventToGroup = async (forHost, groupName, eventId) => {
  let transactionId = false;
  initTransactionState();

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(forHost: Address?, groupName: String, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents

        prepare(acct: AuthAccount) {
          if let fromHost = forHost {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
        }

        execute {
          self.FLOATEvents.addEventToGroup(groupName: groupName, eventId: eventId)
          log("Added an event to a group.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Optional(t.Address)),
        arg(groupName, t.String),
        arg(parseInt(eventId), t.UInt64)
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

export const removeEventFromGroup = async (forHost, groupName, eventId) => {
  let transactionId = false;
  initTransactionState();

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(forHost: Address?, groupName: String, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents

        prepare(acct: AuthAccount) {
          if let fromHost = forHost {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
        }

        execute {
          self.FLOATEvents.removeEventFromGroup(groupName: groupName, eventId: eventId)
          log("Removed an event from a Group.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Optional(t.Address)),
        arg(groupName, t.String),
        arg(parseInt(eventId), t.UInt64)
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


/****************************** GETTERS ******************************/

export const getEvent = async (addr, eventId) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import MetadataViews from 0xCORE

      pub fun main(account: Address, eventId: UInt64): FLOAT.FLOATEventMetadata? {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{MetadataViews.ResolverCollection}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let resolved = floatEventCollection.borrowViewResolver(id: eventId)
        if let view = resolved.resolveView(Type<FLOAT.FLOATEventMetadata>()) {
          return view as! FLOAT.FLOATEventMetadata
        }
        return nil
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
      import MetadataViews from 0xCORE

      pub fun main(account: Address): {String: FLOAT.FLOATEventMetadata} {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{MetadataViews.ResolverCollection}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let floatEvents: [UInt64] = floatEventCollection.getIDs()
        let returnVal: {String: FLOAT.FLOATEventMetadata} = {}
      
        for eventId in floatEvents {
          let resolved = floatEventCollection.borrowViewResolver(id: eventId)
          if let view = resolved.resolveView(Type<FLOAT.FLOATEventMetadata>()) {
            let metadata = view as! FLOAT.FLOATEventMetadata
            returnVal[metadata.name] = metadata
          }
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
  }
}

export const getFLOATs = async (addr) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import MetadataViews from 0xCORE

      pub fun main(account: Address): {UFix64: CombinedMetadata} {
        let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                              .borrow<&FLOAT.Collection{MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the Collection from the account.")
        let ids = floatCollection.getIDs()
        var returnVal: {UFix64: CombinedMetadata} = {}
        for id in ids {
          let resolver = floatCollection.borrowViewResolver(id: id)
          if let floatView = resolver.resolveView(Type<FLOAT.FLOATMetadata>()) {
            let float = floatView as! FLOAT.FLOATMetadata
      
            let eventView = resolver.resolveView(Type<FLOAT.FLOATEventMetadata>()) 
            let event = eventView as! FLOAT.FLOATEventMetadata?
            returnVal[float.dateReceived] = CombinedMetadata(_float: float, _event: event)
          }
        }
      
        return returnVal
      }
      
      pub struct CombinedMetadata {
          pub let float: FLOAT.FLOATMetadata
          pub let event: FLOAT.FLOATEventMetadata?
      
          init(
              _float: FLOAT.FLOATMetadata,
              _event:FLOAT.FLOATEventMetadata?
          ) {
              self.float = _float
              self.event = _event
          }
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address)
      ]
    })
    return Object.values(queryResult) || {};
  } catch (e) {
    console.log(e)
  }
}

export const getFLOAT = async (addr, id) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import MetadataViews from 0xCORE

      pub fun main(account: Address, id: UInt64): CombinedMetadata? {
        let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                              .borrow<&FLOAT.Collection{MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the Collection from the account.")
        let resolved = floatCollection.borrowViewResolver(id: id)
        if let floatView = resolved.resolveView(Type<FLOAT.FLOATMetadata>()) {
          let float = floatView as! FLOAT.FLOATMetadata
      
          let eventView = resolved.resolveView(Type<FLOAT.FLOATEventMetadata>()) 
          let event = eventView as! FLOAT.FLOATEventMetadata?
          return CombinedMetadata(
            _float: float,
            _event: event
          )
        }
        return nil
      }
      
      pub struct CombinedMetadata {
          pub let float: FLOAT.FLOATMetadata
          pub let event: FLOAT.FLOATEventMetadata?
      
          init(
              _float: FLOAT.FLOATMetadata,
              _event:FLOAT.FLOATEventMetadata?
          ) {
              self.float = _float
              self.event = _event
          }
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address),
        arg(id, t.UInt64)
      ]
    })
    // console.log(queryResult)
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

export const getHoldersInEvent = async (addr, eventId) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(account: Address, eventId: UInt64): {UInt64: FLOAT.TokenIdentifier} {
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

      pub fun main(account: Address, eventId: UInt64): {Address: FLOAT.TokenIdentifier} {
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

      pub fun main(hostAddress: Address, eventId: UInt64, accountAddress: Address): FLOAT.TokenIdentifier? {
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

      pub fun main(hostAddress: Address, eventId: UInt64, serial: UInt64): FLOAT.TokenIdentifier? {
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
    return queryResult;
  } catch (e) {
    console.log(e);
  }
}

export const getCanMintForThem = async (address) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import SharedAccount from 0xFLOAT

      pub fun main(address: Address): [Address] {
        let infoPublic = getAccount(address).getCapability(SharedAccount.InfoPublicPath)
                                    .borrow<&SharedAccount.Info{SharedAccount.InfoPublic}>()
                                    ?? panic("Could not borrow the InfoPublic from the account.")
        return infoPublic.getCanMintForThem()
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

export const getAllowed = async (address) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import SharedAccount from 0xFLOAT

      pub fun main(address: Address): [Address] {
        let infoPublic = getAccount(address).getCapability(SharedAccount.InfoPublicPath)
                                    .borrow<&SharedAccount.Info{SharedAccount.InfoPublic}>()
                                    ?? panic("Could not borrow the InfoPublic from the account.")
        return infoPublic.getAllowed()
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
      import MetadataViews from 0xCORE

      pub fun main(account: Address, eventId: UInt64): [String] {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{MetadataViews.ResolverCollection}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let resolved = floatEventCollection.borrowViewResolver(id: eventId)
        if let view = resolved.resolveView(Type<FLOAT.FLOATEventMetadata>()) {
          let metadata = view as! FLOAT.FLOATEventMetadata
          let answer: [String] = []
          for verifier in metadata.verifiers {
            answer.append(verifier.getType().identifier)
          }
        }
        return []
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

export const isSharedWithUser = async (account, user) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import SharedAccount from 0xFLOAT

      pub fun main(account: Address, user: Address): Bool {
        let infoPublic = getAccount(account).getCapability(SharedAccount.InfoPublicPath)
                                    .borrow<&SharedAccount.Info{SharedAccount.InfoPublic}>()
                                    ?? panic("Could not borrow the InfoPublic from the account.")
        return infoPublic.isAllowed(account: user)
      }
      `,
      args: (arg, t) => [
        arg(account, t.Address),
        arg(user, t.Address)
      ]
    })
    return queryResult;
  } catch (e) {
    console.log(e);
  }
}

export const getGroups = async (account) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(account: Address): {String: FLOAT.Group} {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let groups = floatEventCollection.getGroups()

        let answer: {String: FLOAT.Group} = {}
        for groupName in groups {
          answer[groupName] = floatEventCollection.getGroup(groupName: groupName)
        }

        return answer
      }
      `,
      args: (arg, t) => [
        arg(account, t.Address)
      ]
    })
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

export const getEventsInGroup = async (account, groupName) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import MetadataViews from 0xCORE

      pub fun main(account: Address, groupName: String): [FLOAT.FLOATEventMetadata] {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let group = floatEventCollection.getGroup(groupName: groupName)
        let eventIds = group.getEvents()

        let answer: [FLOAT.FLOATEventMetadata] = []
        for eventId in eventIds {
          let resolver = floatEventCollection.borrowViewResolver(id: eventId)
          let view = resolver.resolveView(Type<FLOAT.FLOATEventMetadata>())! as! FLOAT.FLOATEventMetadata
          answer.append(view)
        }

        return answer
      }
      `,
      args: (arg, t) => [
        arg(account, t.Address),
        arg(groupName, t.String)
      ]
    })
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

export const getGroup = async (account, groupName) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(account: Address, groupName: String): FLOAT.Group {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        return floatEventCollection.getGroup(groupName: groupName)
      }
      `,
      args: (arg, t) => [
        arg(account, t.Address),
        arg(groupName, t.String)
      ]
    })
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