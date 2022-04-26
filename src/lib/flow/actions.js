import { browser } from '$app/env';

import * as fcl from "@samatech/onflow-fcl-esm";

import "./config.js";
import { flowTokenIdentifier } from './config.js';
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
  toggleClaimingInProgress,
  addGroupInProgress,
  addGroupStatus,
  floatDeletionInProgress,
  floatDeletionStatus,
  floatTransferInProgress,
  floatTransferStatus,
  addEventToGroupInProgress,
  addEventToGroupStatus,
  removeEventFromGroupStatus,
  removeEventFromGroupInProgress,
  deleteGroupInProgress,
  deleteGroupStatus,
  deleteEventInProgress,
  deleteEventStatus,
  floatDistributingManyStatus,
  floatDistributingManyInProgress,
  setupAccountInProgress,
  setupAccountStatus
} from './stores.js';

import { draftFloat } from '$lib/stores';
import { respondWithError, respondWithSuccess } from '$lib/response';
import { parseErrorMessageFromFCL } from './utils.js';
import { notifications } from "$lib/notifications";

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
    timelock: draftFloat.timelock ? true : false,
    dateStart: draftFloat.startTime ? +new Date(draftFloat.startTime) / 1000 : 0,
    timePeriod: draftFloat.startTime && draftFloat.endTime ? (+new Date(draftFloat.endTime) / 1000) - (+new Date(draftFloat.startTime) / 1000) : 0,
    secret: draftFloat.claimCodeEnabled ? true : false,
    secrets: secrets,
    limited: draftFloat.quantity ? true : false,
    capacity: draftFloat.quantity ? draftFloat.quantity : 0,
    initialGroups: draftFloat.initialGroup ? [draftFloat.initialGroup] : [],
    flowTokenPurchase: draftFloat.flowTokenPurchase ? true : false,
    flowTokenCost: draftFloat.flowTokenPurchase ? String(draftFloat.flowTokenPurchase.toFixed(2)) : "0.0"
  };
}

/****************************** SETTERS ******************************/

export const setupAccount = async () => {

  setupAccountInProgress.set(true);

  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE
      import GrantedAccountAccess from 0xFLOAT

      transaction {

        prepare(acct: AuthAccount) {
          // SETUP COLLECTION
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }

          // SETUP FLOATEVENTS
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }

          // SETUP SHARED MINTING
          if acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath) == nil {
              acct.save(<- GrantedAccountAccess.createInfo(), to: GrantedAccountAccess.InfoStoragePath)
              acct.link<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>
                      (GrantedAccountAccess.InfoPublicPath, target: GrantedAccountAccess.InfoStoragePath)
          }
        }

        execute {
          log("Finished setting up the account for FLOATs.")
        }
      }
      `,
      args: (arg, t) => [
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
          setupAccountStatus.set(respondWithSuccess());
        } else {
          setupAccountStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        setupAccountInProgress.set(false);
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    setupAccountStatus.set(false);
    transactionStatus.set(99)
    console.log(e)

    setTimeout(() => transactionInProgress.set(false), 10000)
  }
}

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
      import GrantedAccountAccess from 0xFLOAT

      transaction(
        forHost: Address, 
        claimable: Bool, 
        name: String, 
        description: String, 
        image: String, 
        url: String, 
        transferrable: Bool, 
        timelock: Bool, 
        dateStart: UFix64, 
        timePeriod: UFix64, 
        secret: Bool, 
        secrets: [String], 
        limited: Bool, 
        capacity: UInt64, 
        initialGroups: [String], 
        flowTokenPurchase: Bool, 
        flowTokenCost: UFix64
      ) {
      
        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
          // SETUP COLLECTION
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // SETUP FLOATEVENTS
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }
      
          // SETUP SHARED MINTING
          if acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath) == nil {
              acct.save(<- GrantedAccountAccess.createInfo(), to: GrantedAccountAccess.InfoStoragePath)
              acct.link<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>
                      (GrantedAccountAccess.InfoPublicPath, target: GrantedAccountAccess.InfoStoragePath)
          }
          
          if forHost != acct.address {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: forHost)
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
          let extraMetadata: {String: AnyStruct} = {}
          if flowTokenPurchase {
            let tokenInfo = FLOAT.TokenInfo(_path: /public/flowTokenReceiver, _price: flowTokenCost)
            extraMetadata["prices"] = {"${flowTokenIdentifier}.FlowToken.Vault": tokenInfo}
          }
          self.FLOATEvents.createEvent(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifiers: verifiers, extraMetadata, initialGroups: initialGroups)
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
        arg(floatObject.initialGroups, t.Array(t.String)),
        arg(floatObject.flowTokenPurchase, t.Bool),
        arg(floatObject.flowTokenCost, t.UFix64)
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 9999
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
      import FLOATVerifiers from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE
      import GrantedAccountAccess from 0xFLOAT
      import FlowToken from 0xFLOWTOKEN

      transaction(eventId: UInt64, host: Address, secret: String?) {
 
        let FLOATEvent: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}
        let Collection: &FLOAT.Collection
        let FlowTokenVault: &FlowToken.Vault
      
        prepare(acct: AuthAccount) {
          // SETUP COLLECTION
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // SETUP FLOATEVENTS
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }
      
          // SETUP SHARED MINTING
          if acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath) == nil {
              acct.save(<- GrantedAccountAccess.createInfo(), to: GrantedAccountAccess.InfoStoragePath)
              acct.link<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>
                      (GrantedAccountAccess.InfoPublicPath, target: GrantedAccountAccess.InfoStoragePath)
          }
      
          let FLOATEvents = getAccount(host).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the public FLOATEvents from the host.")
          self.FLOATEvent = FLOATEvents.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist.")
      
          self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                              ?? panic("Could not get the Collection from the signer.")
          
          self.FlowTokenVault = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                                  ?? panic("Could not borrow the FlowToken.Vault from the signer.")
        }
      
        execute {
          let params: {String: AnyStruct} = {}
      
          // If the FLOAT has a secret phrase on it
          if let unwrappedSecret = secret {
            params["secretPhrase"] = unwrappedSecret
          }
       
          // If the FLOAT costs something
          if let prices = self.FLOATEvent.getPrices() {
            log(prices)
            let payment <- self.FlowTokenVault.withdraw(amount: prices[self.FlowTokenVault.getType().identifier]!.price)
            self.FLOATEvent.purchase(recipient: self.Collection, params: params, payment: <- payment)
            log("Purchased the FLOAT.")
          }
          // If the FLOAT is free 
          else {
            self.FLOATEvent.claim(recipient: self.Collection, params: params)
            log("Claimed the FLOAT.")
          }
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
      import GrantedAccountAccess from 0xFLOAT

      transaction(forHost: Address, eventId: UInt64, recipient: Address) {

        let FLOATEvents: &FLOAT.FLOATEvents
        let FLOATEvent: &FLOAT.FLOATEvent
        let RecipientCollection: &FLOAT.Collection{NonFungibleToken.CollectionPublic}

        prepare(acct: AuthAccount) {
          // SETUP COLLECTION
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }

          // SETUP FLOATEVENTS
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }

          // SETUP SHARED MINTING
          if acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath) == nil {
              acct.save(<- GrantedAccountAccess.createInfo(), to: GrantedAccountAccess.InfoStoragePath)
              acct.link<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>
                      (GrantedAccountAccess.InfoPublicPath, target: GrantedAccountAccess.InfoStoragePath)
          }

          if forHost != acct.address {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: forHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }

          self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId) ?? panic("This event does not exist.")
          self.RecipientCollection = getAccount(recipient).getCapability(FLOAT.FLOATCollectionPublicPath)
                                      .borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>()
                                      ?? panic("Could not get the public FLOAT Collection from the recipient.")
        }

        execute {
          self.FLOATEvent.mint(recipient: self.RecipientCollection)
          log("Distributed the FLOAT.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Address),
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
        if (res.statusCode === 0) {
          floatDistributingStatus.set(respondWithSuccess());
          notifications.info(`You successfuly distributed a FLOAT!`);
        } else {
          floatDistributingStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        floatDistributingInProgress.set(false);

        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99)
    floatDistributingStatus.set(respondWithError(e));
    floatDistributingInProgress.set(false);

    console.log(e)
  }
}

export const distributeDirectlyMany = async (forHost, eventId, recipients) => {

  let transactionId = false;
  initTransactionState()

  floatDistributingManyInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE
      import GrantedAccountAccess from 0xFLOAT

      transaction(forHost: Address, eventId: UInt64, recipients: [Address]) {

        let FLOATEvents: &FLOAT.FLOATEvents
        let FLOATEvent: &FLOAT.FLOATEvent
        let RecipientCollections: [&FLOAT.Collection{NonFungibleToken.CollectionPublic}]
      
        prepare(acct: AuthAccount) {
          // SETUP COLLECTION
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // SETUP FLOATEVENTS
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }
      
          // SETUP SHARED MINTING
          if acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath) == nil {
              acct.save(<- GrantedAccountAccess.createInfo(), to: GrantedAccountAccess.InfoStoragePath)
              acct.link<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>
                      (GrantedAccountAccess.InfoPublicPath, target: GrantedAccountAccess.InfoStoragePath)
          }
      
          if forHost != acct.address {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: forHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
      
          self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId) ?? panic("This event does not exist.")
          self.RecipientCollections = []
          for recipient in recipients {
            if let recipientCollection = getAccount(recipient).getCapability(FLOAT.FLOATCollectionPublicPath).borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>() {
              self.RecipientCollections.append(recipientCollection)
            }
          }
        }
      
        execute {
          //
          // Give the "recipients" a FLOAT from the event with "id"
          //
      
          self.FLOATEvent.batchMint(recipients: self.RecipientCollections)
          log("Distributed the FLOAT.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Address),
        arg(parseInt(eventId), t.UInt64),
        arg(recipients, t.Array(t.Address))
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 9999
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if (res.status === 4) {
        if (res.statusCode === 0) {
          floatDistributingManyStatus.set(respondWithSuccess());
          notifications.info(`You successfuly distributed FLOATs!`);
        } else {
          floatDistributingManyStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        floatDistributingManyInProgress.set(false);

        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99)
    floatDistributingManyStatus.set(respondWithError(e));
    floatDistributingManyInProgress.set(false);

    console.log(e)
  }
}

export const deleteFLOAT = async (id) => {

  let transactionId = false;
  initTransactionState();

  floatDeletionInProgress.set(true);

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
          destroy self.Collection.withdraw(withdrawID: id)
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
        if (res.statusCode === 0) {
          floatDeletionStatus.set(respondWithSuccess());
        } else {
          floatDeletionStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        floatDeletionInProgress.set(false);

        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99);
    floatDeletionInProgress.set(false);
    floatDeletionStatus.set(respondWithError(e))
    console.log(e)
  }
}

export const transferFLOAT = async (id, recipient) => {

  let transactionId = false;
  initTransactionState()

  floatTransferInProgress.set(true);

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
      
        pre {
          self.Collection.borrowFLOAT(id: id) != nil:
            "You do not own this FLOAT."
          self.Collection.borrowFLOAT(id: id)!.getEventMetadata() != nil:
            "Could not borrow the public FLOAT Event data."
          self.Collection.borrowFLOAT(id: id)!.getEventMetadata()!.transferrable:
            "This FLOAT is not giftable on the FLOAT platform."
        }
      
        execute {
          self.RecipientCollection.deposit(token: <- self.Collection.withdraw(withdrawID: id))
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
        if (res.statusCode === 0) {
          floatTransferStatus.set(respondWithSuccess());
        } else {
          floatTransferStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        floatTransferInProgress.set(false);
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99);
    floatTransferInProgress.set(false);
    floatTransferStatus.set(respondWithError(e));

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

      transaction(forHost: Address, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
        let FLOATEvent: &FLOAT.FLOATEvent
      
        prepare(acct: AuthAccount) {
          if forHost != acct.address {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: forHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
      
          self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId) ?? panic("This event does not exist.")
        }
      
        execute {
          self.FLOATEvent.toggleClaimable()
          log("Toggled the FLOAT Event.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Address),
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

      transaction(forHost: Address, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
        let FLOATEvent: &FLOAT.FLOATEvent
      
        prepare(acct: AuthAccount) {
          if forHost != acct.address {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: forHost)
          } else {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
      
          self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId) ?? panic("This event does not exist.")
        }
      
        execute {
          self.FLOATEvent.toggleTransferrable()
          log("Toggled the FLOAT Event.")
        }
      }
      `,
      args: (arg, t) => [
        arg(forHost, t.Address),
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
  initTransactionState();

  deleteEventInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE
      import GrantedAccountAccess from 0xFLOAT

      transaction(forHost: Address, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
          // SETUP COLLECTION
          if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
              acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                      (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
          }
      
          // SETUP FLOATEVENTS
          if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                      (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
          }
      
          // SETUP SHARED MINTING
          if acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath) == nil {
              acct.save(<- GrantedAccountAccess.createInfo(), to: GrantedAccountAccess.InfoStoragePath)
              acct.link<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>
                      (GrantedAccountAccess.InfoPublicPath, target: GrantedAccountAccess.InfoStoragePath)
          }
      
          if forHost != acct.address {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: forHost)
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
        arg(forHost, t.Address),
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
        if (res.statusCode === 0) {
          deleteEventStatus.set(respondWithSuccess());
        } else {
          deleteEventStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        deleteEventInProgress.set(false);
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99);
    deleteEventStatus.set(respondWithError(e));
    deleteEventInProgress.set(false);
    console.log(e);
  }
}

export const addSharedMinter = async (receiver) => {
  let transactionId = false;
  initTransactionState();

  addSharedMinterInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import GrantedAccountAccess from 0xFLOAT

      transaction (receiver: Address) {

        let Info: &GrantedAccountAccess.Info
        
        prepare(acct: AuthAccount) {
          // set up the FLOAT Collection where users will store their FLOATs
          if acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath) == nil {
              acct.save(<- GrantedAccountAccess.createInfo(), to: GrantedAccountAccess.InfoStoragePath)
              acct.link<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>
                      (GrantedAccountAccess.InfoPublicPath, target: GrantedAccountAccess.InfoStoragePath)
          }

          self.Info = acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath)!
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
      import GrantedAccountAccess from 0xFLOAT

      transaction(user: Address) {

        let Info: &GrantedAccountAccess.Info
      
        prepare(acct: AuthAccount) {
          self.Info = acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath)
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

export const createGroup = async (draftGroup) => {
  let transactionId = false;
  initTransactionState();

  addGroupInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE
      import GrantedAccountAccess from 0xFLOAT

      transaction(groupName: String, image: String, description: String) {

        let FLOATEvents: &FLOAT.FLOATEvents

        prepare(acct: AuthAccount) {
            // SETUP COLLECTION
            if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
                acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
                acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                        (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
            }

            // SETUP FLOATEVENTS
            if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
              acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
              acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                        (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
            }

            // SETUP SHARED MINTING
            if acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath) == nil {
                acct.save(<- GrantedAccountAccess.createInfo(), to: GrantedAccountAccess.InfoStoragePath)
                acct.link<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>
                        (GrantedAccountAccess.InfoPublicPath, target: GrantedAccountAccess.InfoStoragePath)
            }

            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")

        }

        execute {
          self.FLOATEvents.createGroup(groupName: groupName, image: image, description: description)
          log("Created a new Group.")
        }
      }
      `,
      args: (arg, t) => [
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
        if (res.statusCode === 0) {
          addGroupStatus.set(respondWithSuccess());
        } else {
          addGroupStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        addGroupInProgress.set(false);

        setTimeout(() => transactionInProgress.set(false), 2000);
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99);
    addGroupInProgress.set(false);
    addGroupStatus.set(respondWithError(e));
    console.log(e);
  }
}

export const deleteGroup = async (groupName) => {
  let transactionId = false;
  initTransactionState();

  deleteGroupInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(groupName: String) {

        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
        }
      
        execute {
          self.FLOATEvents.deleteGroup(groupName: groupName)
          log("Deleted a Group.")
        }
      }
      `,
      args: (arg, t) => [
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
        if (res.statusCode === 0) {
          deleteGroupStatus.set(respondWithSuccess());
        } else {
          deleteGroupStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        deleteGroupInProgress.set(false);
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99);
    deleteGroupInProgress.set(false);
    deleteGroupStatus.set(respondWithError(e));
    console.log(e)
  }
}

export const addEventToGroup = async (forHost, groupName, eventId) => {
  let transactionId = false;
  initTransactionState();

  addEventToGroupInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(forHost: Address, groupName: String, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
          if forHost != acct.address {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: forHost)
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
        arg(forHost, t.Address),
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
        if (res.statusCode === 0) {
          notifications.info(`You successfuly added this event to a Group!`);
          addEventToGroupStatus.set(respondWithSuccess());
        } else {
          addEventToGroupStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        addEventToGroupInProgress.set(false);
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99);
    addEventToGroupStatus.set(respondWithError(e));
    addEventToGroupInProgress.set(false);
    console.log(e)
  }
}

export const removeEventFromGroup = async (forHost, groupName, eventId) => {
  let transactionId = false;
  initTransactionState();

  removeEventFromGroupInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `
      import FLOAT from 0xFLOAT

      transaction(forHost: Address, groupName: String, eventId: UInt64) {

        let FLOATEvents: &FLOAT.FLOATEvents
      
        prepare(acct: AuthAccount) {
          if forHost != acct.address {
            let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("Could not borrow the FLOATEvents from the signer.")
            self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: forHost)
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
        arg(forHost, t.Address),
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
        if (res.statusCode === 0) {
          removeEventFromGroupStatus.set(respondWithSuccess());
        } else {
          removeEventFromGroupStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        removeEventFromGroupInProgress.set(false);
        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

    let res = await fcl.tx(transactionId).onceSealed()
    return res;

  } catch (e) {
    transactionStatus.set(99);
    removeEventFromGroupStatus.set(respondWithError(e));
    removeEventFromGroupInProgress.set(false);
    console.log(e)
  }
}


/****************************** GETTERS ******************************/

export const isSetup = async (addr) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT
      import NonFungibleToken from 0xCORE
      import MetadataViews from 0xCORE
      import GrantedAccountAccess from 0xFLOAT

      pub fun main(accountAddr: Address): Bool {
        let acct = getAccount(accountAddr)

        if acct.getCapability<&FLOAT.Collection{FLOAT.CollectionPublic}>(FLOAT.FLOATCollectionPublicPath).borrow() == nil {
            return false
        }
      
        if acct.getCapability<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>(FLOAT.FLOATEventsPublicPath).borrow() == nil {
          return false
        }
      
        if acct.getCapability<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>(GrantedAccountAccess.InfoPublicPath).borrow() == nil {
            return false
        }

        return true
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address)
      ]
    })
    return queryResult;
  } catch (e) {
    console.log(e);
  }
}

export const getEvent = async (addr, eventId) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(account: Address, eventId: UInt64): FLOATEventMetadata {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let event = floatEventCollection.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist in the account")
        return FLOATEventMetadata(
          _claimable: event.claimable, 
          _dateCreated: event.dateCreated, 
          _description: event.description, 
          _eventId: event.eventId, 
          _extraMetadata: event.getExtraMetadata(), 
          _groups: event.getGroups(), 
          _host: event.host, 
          _image: event.image, 
          _name: event.name, 
          _totalSupply: event.totalSupply, 
          _transferrable: event.transferrable, 
          _url: event.url, 
          _verifiers: event.getVerifiers()
        )
      }

      pub struct FLOATEventMetadata {
        pub let claimable: Bool
        pub let dateCreated: UFix64
        pub let description: String 
        pub let eventId: UInt64
        pub let extraMetadata: {String: AnyStruct}
        pub let groups: [String]
        pub let host: Address
        pub let image: String 
        pub let name: String
        pub let totalSupply: UInt64
        pub let transferrable: Bool
        pub let url: String
        pub let verifiers: {String: [{FLOAT.IVerifier}]}

        init(
            _claimable: Bool,
            _dateCreated: UFix64,
            _description: String, 
            _eventId: UInt64,
            _extraMetadata: {String: AnyStruct},
            _groups: [String],
            _host: Address, 
            _image: String, 
            _name: String,
            _totalSupply: UInt64,
            _transferrable: Bool,
            _url: String,
            _verifiers: {String: [{FLOAT.IVerifier}]}
        ) {
            self.claimable = _claimable
            self.dateCreated = _dateCreated
            self.description = _description
            self.eventId = _eventId
            self.extraMetadata = _extraMetadata
            self.groups = _groups
            self.host = _host
            self.image = _image
            self.name = _name
            self.transferrable = _transferrable
            self.totalSupply = _totalSupply
            self.url = _url
            self.verifiers = _verifiers
        }
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address),
        arg(parseInt(eventId), t.UInt64)
      ]
    })
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

      pub fun main(account: Address): {UFix64: FLOATEventMetadata} {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let floatEvents: [UInt64] = floatEventCollection.getIDs() 
        let returnVal: {UFix64: FLOATEventMetadata} = {}

        for eventId in floatEvents {
          let event = floatEventCollection.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist in the account")
          let metadata = FLOATEventMetadata(
            _claimable: event.claimable, 
            _dateCreated: event.dateCreated, 
            _description: event.description, 
            _eventId: event.eventId, 
            _extraMetadata: event.getExtraMetadata(), 
            _groups: event.getGroups(), 
            _host: event.host, 
            _image: event.image, 
            _name: event.name, 
            _totalSupply: event.totalSupply, 
            _transferrable: event.transferrable, 
            _url: event.url, 
            _verifiers: event.getVerifiers()
          )
          returnVal[event.dateCreated] = metadata
        }
        return returnVal
      }

      pub struct FLOATEventMetadata {
        pub let claimable: Bool
        pub let dateCreated: UFix64
        pub let description: String 
        pub let eventId: UInt64
        pub let extraMetadata: {String: AnyStruct}
        pub let groups: [String]
        pub let host: Address
        pub let image: String 
        pub let name: String
        pub let totalSupply: UInt64
        pub let transferrable: Bool
        pub let url: String
        pub let verifiers: {String: [{FLOAT.IVerifier}]}

        init(
            _claimable: Bool,
            _dateCreated: UFix64,
            _description: String, 
            _eventId: UInt64,
            _extraMetadata: {String: AnyStruct},
            _groups: [String],
            _host: Address, 
            _image: String, 
            _name: String,
            _totalSupply: UInt64,
            _transferrable: Bool,
            _url: String,
            _verifiers: {String: [{FLOAT.IVerifier}]}
        ) {
            self.claimable = _claimable
            self.dateCreated = _dateCreated
            self.description = _description
            self.eventId = _eventId
            self.extraMetadata = _extraMetadata
            self.groups = _groups
            self.host = _host
            self.image = _image
            self.name = _name
            self.transferrable = _transferrable
            self.totalSupply = _totalSupply
            self.url = _url
            self.verifiers = _verifiers
        }
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
      
      pub fun main(account: Address): {UFix64: CombinedMetadata} {
        let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                              .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                              ?? panic("Could not borrow the Collection from the account.")
        let ids = floatCollection.getIDs()
        var returnVal: {UFix64: CombinedMetadata} = {}
        for id in ids {
          let nft: &FLOAT.NFT = floatCollection.borrowFLOAT(id: id)!
          let eventId = nft.eventId
          let eventHost = nft.eventHost
      
          let event = nft.getEventMetadata()
          returnVal[nft.dateReceived] = CombinedMetadata(_float: nft, _totalSupply: event?.totalSupply, _transferrable: event?.transferrable)
        }
      
        return returnVal
      }
      
      pub struct CombinedMetadata {
          pub let float: &FLOAT.NFT
          pub let totalSupply: UInt64?
          pub let transferrable: Bool?
      
          init(
              _float: &FLOAT.NFT,
              _totalSupply: UInt64?,
              _transferrable: Bool?
          ) {
              self.float = _float
              self.totalSupply = _totalSupply
              self.transferrable = _transferrable
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

      pub fun main(account: Address, id: UInt64): CombinedMetadata? {
        let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                              .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                              ?? panic("Could not borrow the Collection from the account.")
        if let nft: &FLOAT.NFT = floatCollection.borrowFLOAT(id: id) {
          let eventId = nft.eventId
          let eventHost = nft.eventHost
      
          let event = nft.getEventMetadata()
          return CombinedMetadata(_float: nft, _totalSupply: event?.totalSupply, _transferrable: event?.transferrable)
        }
        return nil
      }

      pub struct CombinedMetadata {
          pub let float: &FLOAT.NFT
          pub let totalSupply: UInt64?
          pub let transferrable: Bool?

          init(
              _float: &FLOAT.NFT,
              _totalSupply: UInt64?,
              _transferrable: Bool?
          ) {
              self.float = _float
              self.totalSupply = _totalSupply
              self.transferrable = _transferrable
          }
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address),
        arg(parseInt(id), t.UInt64)
      ]
    })
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
        return floatEventCollection.borrowPublicEventRef(eventId: eventId)!.getCurrentHolders()
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address),
        arg(parseInt(eventId), t.UInt64)
      ]
    })
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
        return floatEventCollection.borrowPublicEventRef(eventId: eventId)!.getClaimed()
      }
      `,
      args: (arg, t) => [
        arg(addr, t.Address),
        arg(parseInt(eventId), t.UInt64)
      ]
    })
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
      
        return floatEventPublic!.hasClaimed(account: accountAddress)
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
        let floatEventPublic = floatEventCollection.borrowPublicEventRef(eventId: eventId)!
      
        return floatEventPublic.getCurrentHolder(serial: serial)
      }
      `,
      args: (arg, t) => [
        arg(hostAddress, t.Address),
        arg(parseInt(eventId), t.UInt64),
        arg(parseInt(serial), t.UInt64)
      ]
    })
    return queryResult;
  } catch (e) {
    console.log(e);
  }
}

export const getAllowed = async (address) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import GrantedAccountAccess from 0xFLOAT

      pub fun main(address: Address): [Address] {
        let infoPublic = getAccount(address).getCapability(GrantedAccountAccess.InfoPublicPath)
                                    .borrow<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>()
                                    ?? panic("Could not borrow the InfoPublic from the account.")
        return infoPublic.getAllowed()
      }
      `,
      args: (arg, t) => [
        arg(address, t.Address)
      ]
    })
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
    return queryResult || {};
  } catch (e) {
    console.log(e);
  }
}

export const isSharedWithUser = async (account, user) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import GrantedAccountAccess from 0xFLOAT

      pub fun main(account: Address, user: Address): Bool {
        let infoPublic = getAccount(account).getCapability(GrantedAccountAccess.InfoPublicPath)
                                    .borrow<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>()
                                    ?? panic("Could not borrow the InfoPublic from the account.")
        return infoPublic.isAllowed(account: user) || account == user
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
    return false;
  }
}

export const getGroups = async (account) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(account: Address): {String: &FLOAT.Group} {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let groups = floatEventCollection.getGroups()
      
        let answer: {String: &FLOAT.Group} = {}
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
    return {};
  }
}

export const getEventsInGroup = async (account, groupName) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(account: Address, groupName: String): [FLOATEventMetadata] {
        let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the FLOAT Events Collection from the account.")
        let group = floatEventCollection.getGroup(groupName: groupName) ?? panic("This group doesn't exist.")
        let eventIds = group.getEvents()

        let answer: [FLOATEventMetadata] = []
        for eventId in eventIds {
          let event = floatEventCollection.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist in the account")
          let metadata = FLOATEventMetadata(
            _claimable: event.claimable, 
            _dateCreated: event.dateCreated, 
            _description: event.description, 
            _eventId: event.eventId, 
            _extraMetadata: event.getExtraMetadata(), 
            _groups: event.getGroups(), 
            _host: event.host, 
            _image: event.image, 
            _name: event.name, 
            _totalSupply: event.totalSupply, 
            _transferrable: event.transferrable, 
            _url: event.url, 
            _verifiers: event.getVerifiers()
          )
          answer.append(metadata)
        }

        return answer
      }

      pub struct FLOATEventMetadata {
        pub let claimable: Bool
        pub let dateCreated: UFix64
        pub let description: String 
        pub let eventId: UInt64
        pub let extraMetadata: {String: AnyStruct}
        pub let groups: [String]
        pub let host: Address
        pub let image: String 
        pub let name: String
        pub let totalSupply: UInt64
        pub let transferrable: Bool
        pub let url: String
        pub let verifiers: {String: [{FLOAT.IVerifier}]}

        init(
            _claimable: Bool,
            _dateCreated: UFix64,
            _description: String, 
            _eventId: UInt64,
            _extraMetadata: {String: AnyStruct},
            _groups: [String],
            _host: Address, 
            _image: String, 
            _name: String,
            _totalSupply: UInt64,
            _transferrable: Bool,
            _url: String,
            _verifiers: {String: [{FLOAT.IVerifier}]}
        ) {
            self.claimable = _claimable
            self.dateCreated = _dateCreated
            self.description = _description
            self.eventId = _eventId
            self.extraMetadata = _extraMetadata
            self.groups = _groups
            self.host = _host
            self.image = _image
            self.name = _name
            self.transferrable = _transferrable
            self.totalSupply = _totalSupply
            self.url = _url
            self.verifiers = _verifiers
        }
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

      pub fun main(account: Address, groupName: String): &FLOAT.Group? {
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

export const getStats = async () => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOAT from 0xFLOAT

      pub fun main(): [UInt64] {
        let info: [UInt64] = []
        info.append(FLOAT.totalSupply)
        info.append(FLOAT.totalFLOATEvents)
        return info
      }
      `,
      args: (arg, t) => [
      ]
    })
    return queryResult || [];
  } catch (e) {
    console.log(e);
  }
}

export const getFlowTokenBalance = async (account) => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FlowToken from 0xFLOWTOKEN
      import FungibleToken from 0xFUNGIBLETOKEN

      pub fun main(account: Address): UFix64 {
        let vault = getAccount(account).getCapability(/public/flowTokenBalance)
                      .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
                      ?? panic("Does not have a FlowToken Vault")
        return vault.balance
      }
      `,
      args: (arg, t) => [
        fcl.arg(account, t.Address)
      ]
    })
    return queryResult || [];
  } catch (e) {
    console.log(e);
  }
}

export const resolveAddressObject = async (lookup) => {
  let answer = {
    resolvedNames: {
      find: "",
      fn: ""
    },
    address: ""
  };
  let rootLookup = lookup.split('.')[0];
  // const findCache = JSON.parse(localStorage.getItem('findCache')) || {};
  // if (findCache && findCache[lookup]) {
  //   return Promise.resolve(findCache[lookup]);
  // }
  try {
    if (rootLookup.length === 18 && rootLookup.substring(0, 2) === '0x') {
      answer.address = lookup;
      answer.resolvedNames.find = await fcl.query({
        cadence: `
        import FIND from 0xFIND

        pub fun main(address: Address): String? {
            let name = FIND.reverseLookup(address)
            return name?.concat(".find")
        }
        `,
        args: (arg, t) => [
          arg(lookup, t.Address)
        ]
      });

      answer.resolvedNames.fn = await fcl.query({
        cadence: `
        import Domains from 0xFN
      
        pub fun main(address: Address): String? {
    
          let account = getAccount(address)
          let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
      
          if collectionCap.check() != true {
            return nil
          }
      
          var flownsName = ""
          let collection = collectionCap.borrow()!
          let ids = collection.getIDs()
          
          for id in ids {
            let domain = collection.borrowDomain(id: id)!
            let isDefault = domain.getText(key: "isDefault")
            flownsName = domain.getDomainName()
            if isDefault == "true" {
              break
            }
          }
      
          return flownsName
        }
        `,
        args: (arg, t) => [
          arg(lookup, t.Address)
        ]
      });
    } else if (lookup.includes('.find')) {
      answer.resolvedNames.find = lookup;
      answer.address = await fcl.query({
        cadence: `
        import FIND from 0xFIND
  
        pub fun main(name: String) : Address?  {
          return FIND.lookupAddress(name)
        }
        `,
        args: (arg, t) => [
          arg(rootLookup, t.String)
        ]
      })
    } else if (lookup.includes('.fn')) {
      answer.resolvedNames.fn = lookup;
      answer.address = await fcl.query({
        cadence: `
        import Flowns from 0xFN
        import Domains from 0xFN
        pub fun main(name: String): Address? {
          
          let prefix = "0x"
          let rootHash = Flowns.hash(node: "", lable: "fn")
          let nameHash = prefix.concat(Flowns.hash(node: rootHash, lable: name))
          let address = Domains.getRecords(nameHash)
        
          return address
        }
        `,
        args: (arg, t) => [
          arg(rootLookup, t.String)
        ]
      })
    }
    // findCache[lookup] = queryResult;
    // localStorage.setItem('findCache', JSON.stringify(findCache));
    return answer;
  } catch (e) {
    return answer;
  }
}

function initTransactionState() {
  transactionInProgress.set(true);
  transactionStatus.set(-1);
  floatClaimedStatus.set(false);
  eventCreatedStatus.set(false);
}