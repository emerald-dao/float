import { browser } from '$app/env';

import * as fcl from "@onflow/fcl";

import "./config.js";
import { addressMap, flowTokenIdentifier } from './config.js';
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
  setupAccountStatus,
  incinerateInProgress,
  incinerateStatus,
  eventSeries,
} from './stores.js';
import { get } from 'svelte/store'

import * as cadence from './cadence';

import { draftFloat, walletModal, currentWallet } from '$lib/stores';
import { respondWithError, respondWithSuccess } from '$lib/response';
import { parseErrorMessageFromFCL } from './utils.js';
import { notifications } from "$lib/notifications";
import { config } from "@onflow/fcl";

if (browser) {
  // set Svelte $user store to currentUser, 
  // so other components can access it
  fcl.currentUser.subscribe(user.set, [])
}

// Lifecycle FCL Auth functions
export const unauthenticate = () => fcl.unauthenticate();
export const authenticate = () => {
  walletModal.set(true);
};

const configureFCL = (wallet) => {
  if (wallet === 'blocto') {
    config()
      .put("discovery.wallet", import.meta.env.VITE_BLOCTO_DISCOVERY)
      .put("discovery.wallet.method", import.meta.env.VITE_FLOW_NETWORK === 'testnet' ? "HTTP/POST" : "IFRAME/RPC")
  } else if (wallet === 'dapper') {
    config()
      .put("discovery.wallet", import.meta.env.VITE_DAPPER_DISCOVERY)
      .put("discovery.wallet.method", "POP/RPC")
  }
  else if (wallet === 'lilico') {
    config()
      .put("discovery.wallet", import.meta.env.VITE_LILICO_DISCOVERY)
      .put("discovery.wallet.method", "EXT/RPC")
  }
}

export const configureFCLAndLogin = async (wallet) => {
  currentWallet.set(wallet);
  configureFCL(wallet);
  await fcl.authenticate();
  walletModal.set(false);
}

const convertDraftFloat = (draftFloat) => {
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
    secret: draftFloat.claimCodeEnabled && draftFloat.secretPK ? true : false,
    secretPK: draftFloat.claimCodeEnabled && draftFloat.secretPK ? draftFloat.secretPK : '',
    limited: draftFloat.quantity ? true : false,
    capacity: draftFloat.quantity ? draftFloat.quantity.toString() : '0',
    initialGroups: draftFloat.initialGroup ? [draftFloat.initialGroup] : [],
    flowTokenPurchase: draftFloat.flowTokenPurchase ? true : false,
    flowTokenCost: draftFloat.flowTokenPurchase ? String(draftFloat.flowTokenPurchase.toFixed(2)) : "0.0",
    minimumBalanceToggle: draftFloat.minimumBalance ? true : false,
    minimumBalance: draftFloat.minimumBalance ? String(draftFloat.minimumBalance.toFixed(2)) : "0.0"
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
  console.log(floatObject);

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
        secretPK: String, 
        limited: Bool, 
        capacity: UInt64, 
        initialGroups: [String], 
        flowTokenPurchase: Bool, 
        flowTokenCost: UFix64,
        minimumBalanceToggle: Bool,
        minimumBalance: UFix64
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
          var SecretV2: FLOATVerifiers.SecretV2? = nil
          var Limited: FLOATVerifiers.Limited? = nil
          var MinimumBalance: FLOATVerifiers.MinimumBalance? = nil
          var verifiers: [{FLOAT.IVerifier}] = []
          if timelock {
            Timelock = FLOATVerifiers.Timelock(_dateStart: dateStart, _timePeriod: timePeriod)
            verifiers.append(Timelock!)
          }
          if secret {
            SecretV2 = FLOATVerifiers.SecretV2(_publicKey: secretPK)
            verifiers.append(SecretV2!)
          }
          if limited {
            Limited = FLOATVerifiers.Limited(_capacity: capacity)
            verifiers.append(Limited!)
          }
          if minimumBalanceToggle {
            MinimumBalance = FLOATVerifiers.MinimumBalance(_amount: minimumBalance)
            verifiers.append(MinimumBalance!)
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
        arg(floatObject.secretPK, t.String),
        arg(floatObject.limited, t.Bool),
        arg(floatObject.capacity, t.UInt64),
        arg(floatObject.initialGroups, t.Array(t.String)),
        arg(floatObject.flowTokenPurchase, t.Bool),
        arg(floatObject.flowTokenCost, t.UFix64),
        arg(floatObject.minimumBalanceToggle, t.Bool),
        arg(floatObject.minimumBalance, t.UFix64)
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
        arg(eventId, t.UInt64),
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

export const claimFLOATv2 = async (eventId, host, secretSig) => {

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

      transaction(eventId: UInt64, host: Address, secretSig: String?) {
 
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
          if let unwrappedSecretSig = secretSig {
            params["secretSig"] = unwrappedSecretSig
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
        arg(eventId, t.UInt64),
        arg(host, t.Address),
        arg(secretSig, t.Optional(t.String)),
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
        arg(eventId, t.UInt64),
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
          notifications.info(`You successfully distributed a FLOAT!`);
        } else {
          floatDistributingStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
          notifications.info(parseErrorMessageFromFCL(res.errorMessage));
        }
        floatDistributingInProgress.set(false);

        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99)
    floatDistributingStatus.set(respondWithError(e));
    floatDistributingInProgress.set(false);
    notifications.info(parseErrorMessageFromFCL(e));

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
      import FlowStorageFees from 0xFLOWSTORAGEFEES

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
            if FlowStorageFees.defaultTokenAvailableBalance(recipient) >= 0.001 {
              if let recipientCollection = getAccount(recipient).getCapability(FLOAT.FLOATCollectionPublicPath).borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>() {
                self.RecipientCollections.append(recipientCollection)
              }
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
        arg(eventId, t.UInt64),
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
          notifications.info(`You successfully distributed FLOATs!`);
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
      cadence: `import FLOAT from 0xFLOAT

      transaction(id: UInt64) {
      
        let Collection: &FLOAT.Collection
      
        prepare(acct: AuthAccount) {
          self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                              ?? panic("Could not get the Collection from the signer.")
        }
      
        execute {
          self.Collection.delete(id: id)
          log("Destroyed the FLOAT.")
        }
      }`,
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

export const deleteFLOATs = async (ids) => {

  let transactionId = false;
  initTransactionState();

  floatDeletionInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `import FLOAT from 0xFLOAT

      transaction(ids: [UInt64]) {
      
        let Collection: &FLOAT.Collection
      
        prepare(acct: AuthAccount) {
          self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                              ?? panic("Could not get the Collection from the signer.")
        }
      
        execute {
          for id in ids {
            self.Collection.delete(id: id)
          }
          log("Destroyed the FLOAT.")
        }
      }`,
      args: (arg, t) => [
        arg(ids, t.Array(t.UInt64))
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

export const incinerate = async (ids) => {

  let transactionId = false;
  initTransactionState();

  incinerateInProgress.set(true);

  try {
    transactionId = await fcl.mutate({
      cadence: `import FLOATIncinerator from 0xFLOAT
      import FLOAT from 0xFLOAT
      
      transaction(ids: [UInt64]) {
        let Collection: &FLOAT.Collection
        let Incinerator: &FLOATIncinerator.Incinerator
        prepare(signer: AuthAccount) {
          self.Collection = signer.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                              ?? panic("Could not get the Collection from the signer.")
        
          if signer.borrow<&FLOATIncinerator.Incinerator>(from: FLOATIncinerator.IncineratorStoragePath) == nil {
            signer.save(<- FLOATIncinerator.createIncinerator(), to: FLOATIncinerator.IncineratorStoragePath)
            signer.link<&FLOATIncinerator.Incinerator{FLOATIncinerator.IncineratorPublic}>(FLOATIncinerator.IncineratorPublicPath, target: FLOATIncinerator.IncineratorStoragePath)
          }
          self.Incinerator = signer.borrow<&FLOATIncinerator.Incinerator>(from: FLOATIncinerator.IncineratorStoragePath)!
        }
      
        execute {
          self.Incinerator.burn(collection: self.Collection, ids: ids)
        }
      }`,
      args: (arg, t) => [
        arg(ids, t.Array(t.UInt64))
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
          incinerateStatus.set(respondWithSuccess());
          setTimeout(() => incinerateStatus.set(null), 2000);
        } else {
          incinerateStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode));
        }
        incinerateInProgress.set(false);

        setTimeout(() => transactionInProgress.set(false), 2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99);
    incinerateInProgress.set(false);
    incinerateStatus.set(respondWithError(e))
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
      limit: 9999
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
          notifications.info(`You successfully added this event to a Group!`);
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
        arg(eventId, t.UInt64)
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
        arg(id, t.UInt64)
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
        arg(eventId, t.UInt64)
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
        arg(eventId, t.UInt64)
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
        arg(eventId, t.UInt64),
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
        arg(eventId, t.UInt64),
        arg(serial, t.UInt64)
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
        arg(eventId, t.UInt64)
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

export const getIncineratedStats = async () => {
  try {
    let queryResult = await fcl.query({
      cadence: `
      import FLOATIncinerator from 0xFLOAT

      pub fun main(): [UInt64] {
        let info: [UInt64] = []
        info.append(FLOATIncinerator.flameStrength)
        info.append(FLOATIncinerator.totalIncinerated)
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
      // FIXME: no need resolve names in dev
      if (import.meta.env.DEV && import.meta.env.VITE_FLOW_NETWORK === 'testnet') {
        return answer
      }
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
  configureFCL(get(currentWallet));
  console.log(get(currentWallet));
  transactionInProgress.set(true);
  transactionStatus.set(-1);
  floatClaimedStatus.set(false);
  eventCreatedStatus.set(false);
}

/**
 * genrenal method of sending transaction
 * 
 * @param {string} code
 * @param {fcl.ArgsFn} args
 * @param {import('svelte/store').Writable<boolean>} inProgress 
 * @param {import('svelte/store').Writable<boolean>} actionStatus 
 * @param {(string, string)=>void} [onSealed=undefined]
 * @param {number} [gasLimit=9999]
 */
const generalSendTransaction = async (code, args, actionInProgress = undefined, actionStatus = undefined, gasLimit = 9999, onSealed = undefined) => {
  gasLimit = gasLimit || 9999

  actionInProgress && actionInProgress.set(true);

  let transactionId = false;
  initTransactionState();

  try {
    transactionId = await fcl.mutate({
      cadence: code,
      args: args,
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: gasLimit
    })

    txId.set(transactionId);

    return new Promise((resolve, reject) => {
      fcl.tx(transactionId).subscribe(res => {
        transactionStatus.set(res.status)

        if (res.status === 4) {
          if (res.statusCode === 0) {
            actionStatus && actionStatus.set(respondWithSuccess());
          } else {
            actionStatus && actionStatus.set(respondWithError(parseErrorMessageFromFCL(res.errorMessage), res.statusCode))
          }
          actionInProgress && actionInProgress.set(false);
  
          // on sealed callback
          if (typeof onSealed === 'function') {
            onSealed(transactionId, res.statusCode === 0 ? undefined : res.errorMessage)
          }
  
          setTimeout(() => transactionInProgress.set(false), 2000)

          resolve();
        }
      })
    })
  } catch (e) {
    actionInProgress && actionInProgress.set(false);
    actionStatus && actionStatus.set(respondWithError(e));
    transactionStatus.set(99)
    console.log(e)

    setTimeout(() => transactionInProgress.set(false), 10000)
  }
}

/**
 * genrenal method of query transaction
 * 
 * @param {string} code
 * @param {fcl.ArgsFn} args
 * @param {any} defaultValue
 */
const generalQuery = async (code, args, defaultValue = {}) => {
  try {
    const queryResult = await fcl.query({ cadence: code, args })
    return queryResult ?? defaultValue
  } catch (e) {
    console.error(e)
  }
}

/**
____ _  _ ____ _  _ ___    ____ ____ ____ _ ____ ____ 
|___ |  | |___ |\ |  |     [__  |___ |__/ | |___ [__  
|___  \/  |___ | \|  |     ___] |___ |  \ | |___ ___] 
 */
 
// -------------- Setter - Transactions --------------

// **************************
// ** Event Series Builder **
// **************************

/**
 * create a new event series
 * 
 * @param {object} basics basic information
 * @param {string} basics.name
 * @param {string} basics.description
 * @param {string} basics.image
 * @param {object[]} presetEvents
 * @param {object} presetEvents.event
 * @param {string} presetEvents.event.host
 * @param {number} presetEvents.event.id
 * @param {boolean} presetEvents.required
 * @param {number} emptySlotsAmt how many empty slots totally
 * @param {number} emptySlotsAmtRequired how many empty slots is required
 */
export const createEventSeries = async (basics, presetEvents, emptySlotsAmt = 0, emptySlotsAmtRequired = 0) => {
  const reduced = presetEvents.reduce((all, curr) => {
    if (typeof curr.event?.host === 'string' &&
      typeof curr.event?.id === 'string' && 
      (typeof curr.required === 'boolean' || curr.required === undefined)) {
      all.hosts.push(curr.event.host)
      all.eventIds.push(curr.event.id)
      all.required.push(curr.required ?? true)
    }
    return all
  }, { hosts:[], eventIds: [], required: []})

  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txCreateEventSeries, addressMap),
    (arg, t) => [
      arg(basics.name, t.String),
      arg(basics.description, t.String),
      arg(basics.image, t.String),
      arg(String(emptySlotsAmt), t.UInt64),
      arg(emptySlotsAmtRequired ? String(emptySlotsAmtRequired) : '0', t.UInt64),
      arg(reduced.hosts, t.Array(t.Address)),
      arg(reduced.eventIds, t.Array(t.UInt64)),
      arg(reduced.required, t.Array(t.Bool))
    ],
    eventSeries.Creation.InProgress,
    eventSeries.Creation.Status
  )
}

/**
 * add a goal to EventSeries
 * 
 * @param {import('../components/eventseries/types').AddAchievementGoalRequest}
 */
export const addAchievementGoalToEventSeries = async ({type, seriesId, points, params}) => {
  let code
  /** @type {fcl.ArgsFn} */
  let args
  switch (type) {
    case 'byAmount':
      code = cadence.replaceImportAddresses(cadence.txAddEventSeriesGoalByAmount, addressMap)

      const { eventsAmount, requiredEventsAmount } = params || {}
      if (eventsAmount === undefined) {
        throw new Error('eventsAmount is missing')
      }
      args = (arg, t) => [
        arg(seriesId, t.UInt64),
        arg(String(points), t.UInt64),
        arg(String(eventsAmount), t.UInt64),
        arg(String(requiredEventsAmount), t.UInt64),
      ]
      break;

    case 'byPercent':
      code = cadence.replaceImportAddresses(cadence.txAddEventSeriesGoalByPercent, addressMap)

      const { percent } = params || {}
      if (percent === undefined) {
        throw new Error('percent is missing')
      }
      args = (arg, t) => [
        arg(seriesId, t.UInt64),
        arg(String(points), t.UInt64),
        arg((percent / 100.0).toFixed(1), t.UFix64),
      ]
      break;

    case 'bySpecifics':
      code = cadence.replaceImportAddresses(cadence.txAddEventSeriesGoalBySpecifics, addressMap)

      const { events } = params || {}
      if (events === undefined && !Array.isArray(events)) {
        throw new Error('events is missing')
      }
      const reduced = events.reduce((all, curr) => {
        if (typeof curr.host === 'string' && typeof curr.id === 'string') {
          all.hosts.push(curr.host)
          all.eventIds.push(curr.id)
        }
        return all
      }, { hosts:[], eventIds: [] })

      args = (arg, t) => [
        arg(seriesId, t.UInt64),
        arg(String(points), t.UInt64),
        arg(reduced.hosts, t.Array(t.Address)),
        arg(reduced.eventIds, t.Array(t.UInt64)),
      ]
      break;
    default:
      throw new Error("Unknown type")
  }
  return await generalSendTransaction(code, args, 
    eventSeries.AddAchievementGoal.InProgress,
    eventSeries.AddAchievementGoal.Status
  )
}

/**
 * update EventSeries basics
 * 
 * @param {number} seriesId
 * @param {object} basics basic information
 * @param {string} basics.name
 * @param {string} basics.description
 * @param {string} basics.image
 */
export const updateEventseriesBasics = async (seriesId, basics) => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txUpdateEventSeriesBasics, addressMap),
    (arg, t) => [
      arg(seriesId, t.UInt64),
      arg(basics.name, t.String),
      arg(basics.description, t.String),
      arg(basics.image, t.String),
    ],
    eventSeries.UpdateBasics.InProgress,
    eventSeries.UpdateBasics.Status
  )
}

/**
 * update EventSeries slots
 * 
 * @param {number} seriesId
 * @param {object[]} slotsEvents
 * @param {number} slotsEvents.index
 * @param {string} slotsEvents.host
 * @param {number} slotsEvents.eventId
 */
export const updateEventseriesSlots = async (seriesId, slotsEvents) => {
  const reduced = slotsEvents.reduce((all, curr) => {
    if (typeof curr.index === 'string' &&
      typeof curr.host === 'string' &&
      typeof curr.eventId === 'string') {
      all.indexes.push(curr.index)
      all.hosts.push(curr.host)
      all.eventIds.push(curr.eventId)
    }
    return all
  }, { indexes: [], hosts:[], eventIds: []})

  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txUpdateEventSeriesSlots, addressMap),
    (arg, t) => [
      arg(seriesId, t.UInt64),
      arg(reduced.indexes, t.Array(t.Int)),
      arg(reduced.hosts, t.Array(t.Address)),
      arg(reduced.eventIds, t.Array(t.UInt64)),
    ],
    eventSeries.UpdateSlots.InProgress,
    eventSeries.UpdateSlots.Status
  )
}

export const revokeEventSeries = async (seriesId) => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txRevokeEventSeries, addressMap),
    (arg, t) => [
      arg(seriesId, t.UInt64),
    ],
    eventSeries.Revoke.InProgress,
    eventSeries.Revoke.Status
  )
}

/**
 * add treasury strategy
 * 
 * @param {import('../components/eventseries/types').AddStrategyRequest}
 */
export const addTreasuryStrategy = async ({seriesId, strategyMode, deliveryMode, options}) => {
  const strategyModeCode = {
    [cadence.STRATEGY_RAFFLE]: '0',
    [cadence.STRATEGY_QUEUE]: '1'
  }[strategyMode]

  const deliveryModeCode = {
    [cadence.DELIVERY_FT_IDENTICAL]: '0',
    [cadence.DELIVERY_FT_RANDOM]: '1',
    [cadence.DELIVERY_NFT]: '2',
  }[deliveryMode]

  if (strategyModeCode === undefined || deliveryModeCode === undefined) {
    throw new Error('Wrong mode')
  }

  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txAddTreasuryStrategy, addressMap),
    (arg, t) => [
      arg(String(seriesId), t.UInt64),
      arg(String(options?.consumable) === 'true', t.Bool),
      arg(String(options?.threshold), t.UInt64),
      arg(options?.autoStart, t.Bool),
      // State Parameters
      arg(typeof options?.openingEnding !== 'undefined' ?? false, t.Bool),
      arg(options?.openingEnding?.toFixed(1) ?? '0.0', t.UFix64),
      arg(typeof options?.claimableEnding !== 'undefined' ?? false, t.Bool),
      arg(options?.claimableEnding?.toFixed(1) ?? '0.0', t.UFix64),
      arg(typeof options?.minimumValidAmount !== 'undefined' ?? false, t.Bool),
      arg(options?.minimumValidAmount?.toFixed(0) ?? null, t.Optional(t.UInt64)),
      // Delivery Parameters
      arg(String(strategyModeCode), t.UInt8),
      arg(String(options?.maxClaimableShares ?? 1), t.UInt64),
      arg(String(deliveryModeCode), t.UInt8),
      arg(options?.deliveryTokenIdentifier, t.String),
      arg(options?.deliveryParam1?.toFixed(1) ?? null, t.Optional(t.UFix64)),
    ],
    eventSeries.AddTreasuryStrategy.InProgress,
    eventSeries.AddTreasuryStrategy.Status
  )
}

/**
 * let strategy go to next stage
 * 
 * @param {string} seriesId
 * @param {number} strategyIndex
 */
export const nextTreasuryStrategyStage = async (seriesId, strategyIndex, forceClose = false) => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txNextTreasuryStrategyStage, addressMap),
    (arg, t) => [
      arg(seriesId, t.UInt64),
      arg(String(strategyIndex), t.Int),
      arg(!!forceClose, t.Bool)
    ],
    eventSeries.NextTreasuryStrategyStage.InProgress,
    eventSeries.NextTreasuryStrategyStage.Status,
  )
}

/**
 * deposit fungible token to treasury
 * 
 * @param {import('../components/eventseries/types').TreasuryManagementRequeset}
 */
export const depositFungibleTokenToTreasury = async ({seriesId, storagePath, publicPath, amount}) => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txDepositFungibleTokenToTreasury, addressMap),
    (arg, t) => [
      arg(seriesId, t.UInt64),
      arg(storagePath, t.String),
      arg(publicPath, t.String),
      arg(amount.toFixed(8), t.UFix64),
    ],
    eventSeries.TreasuryManegement.InProgress,
    eventSeries.TreasuryManegement.Status
  )
}

/**
 * deposit non-fungible token to treasury
 * 
 * @param {import('../components/eventseries/types').TreasuryManagementRequeset}
 */
export const depositNonFungibleTokenToTreasury = async ({seriesId, storagePath, publicPath, amount}) => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txDepositNonFungibleTokenToTreasury, addressMap),
    (arg, t) => [
      arg(seriesId, t.UInt64),
      arg(storagePath, t.String),
      arg(publicPath, t.String),
      arg(amount.toFixed(0), t.UInt64),
    ],
    eventSeries.TreasuryManegement.InProgress,
    eventSeries.TreasuryManegement.Status,
  )
}

/**
 * Drop treasury's FTs and NFTs
 * 
 * @param {import('../components/eventseries/types').TreasuryManagementRequeset}
 */
export const dropTreasury = async ({seriesId}) => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txDropTreasury, addressMap),
    (arg, t) => [
      arg(seriesId, t.UInt64),
    ],
    eventSeries.TreasuryManegement.InProgress,
    eventSeries.TreasuryManegement.Status,
  )
}

// **********************
// ** Events Collector **
// **********************

/**
 * accompllish event series goals
 * 
 * @param {string} host
 * @param {string} seriesId
 * @param {number[]} goals
 */
export const accomplishGoals = async (host, seriesId, goals) => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txAccomplishGoal, addressMap),
    (arg, t) => [
      arg(host, t.Address),
      arg(seriesId, t.UInt64),
      arg(goals.map(one => one.toFixed(0)), t.Array(t.Int)),
    ],
    eventSeries.AccompllishGoals.InProgress,
    eventSeries.AccompllishGoals.Status,
  )
}

/**
 * claim the rewards from event series treasury
 * 
 * @param {string} host 
 * @param {number} seriesId 
 * @param {number} strategyIndex 
 */
export const claimTreasuryRewards = async (host, seriesId, strategyIndex) => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txClaimTreasuryRewards, addressMap),
    (arg, t) => [
      arg(host, t.Address),
      arg(seriesId, t.UInt64),
      arg(String(strategyIndex), t.Int),
    ],
    eventSeries.ClaimTreasuryRewards.InProgress,
    eventSeries.ClaimTreasuryRewards.Status,
  )
}

/**
 * refresh user strategies status
 * 
 * @param {string} host 
 * @param {number} seriesId 
 */
export const refreshUserStrategiesStatus = async (host, seriesId) => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txRefreshUserStrategiesStatus, addressMap),
    (arg, t) => [
      arg(host, t.Address),
      arg(seriesId, t.UInt64),
    ],
    eventSeries.RefreshUserStatus.InProgress,
    eventSeries.RefreshUserStatus.Status,
  )
}

// For Dev
export const runCleanUp = async () => {
  return await generalSendTransaction(
    cadence.replaceImportAddresses(cadence.txCleanup, addressMap),
    (arg, t) => [],
    eventSeries.Creation.InProgress,
    eventSeries.Creation.Status,
  )
}

// -------------- Getter - Scripts --------------

// ************************
// ** Event Series Users **
// ************************

/**
 * @param {object} item 
 * @returns {import('../components/eventseries/types').EventSeriesData}
 */
const parseEventSeries = (item) => ({
  sequence: item.sequence ? parseInt(item.sequence) : -1,
  identifier: {
    host: item.host,
    id: item.id,
  },
  basics: {
    name: item.display?.name,
    description: item.display?.description,
    image: item.display?.thumbnail?.cid ?? "",
  },
  slots: (item.slots || []).map(one => ({
    required: one.required,
    event: one.event && {
      host: one.event.host,
      id: one.event.eventId ?? one.event.id,
    }
  })),
})

/**
 * Get all event series list
 */
export const getGlobalEventSeriesList = async (page = 0, limit = 20, notClosed = true) => {
  /** @type {import('../components/eventseries/types').EventSeriesData[]} */
  let ret = []
  const raw = await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetGlobalEventSeriesList, addressMap),
    (arg, t) => [
      arg(String(page), t.UInt64),
      arg(String(limit), t.UInt64),
      arg(!!notClosed, t.Bool),
    ],
    []
  )
  if (raw && Object.keys(raw.result ?? {})?.length > 0) {
    ret = Object.values(raw.result).map(parseEventSeries);
  }
  return {
    total: parseInt(raw?.total ?? "0") - 1,
    list: ret
  }
}

/**
 * @param {string} 
 */
export const getEventSeriesList = async (acct) => {
  /** @type {import('../components/eventseries/types').EventSeriesData[]} */
  let ret = []
  const rawDic = await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetEventSeriesList, addressMap),
    (arg, t) => [
      arg(acct, t.Address)
    ],
    []
  )
  if (rawDic && Object.keys(rawDic)?.length > 0) {
    ret = Object.values(rawDic).map(parseEventSeries);
  }
  return ret
}

export const getEventSeries = async (acct, id) => {
  const raw = await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetEventSeries, addressMap),
    (arg, t) => [
      arg(acct, t.Address),
      arg(id, t.UInt64)
    ],
    {}
  )
  if (!raw) return null
  return parseEventSeries(raw)
}

export const getEventSeriesGoals = async (host, id) => {
  const raw = await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetEventSeriesGoals, addressMap),
    (arg, t) => [
      arg(host, t.Address),
      arg(id, t.UInt64),
    ],
    []
  )
  if (!raw) return null
  return raw.map(one => parseRawGoalData(one)).filter(one => !!one)
}

/**
 * @param rawGoal
 * @return {import('../components/eventseries/types').EventSeriesAchievementGoal}
 */
function parseRawGoalData(rawGoal) {
  /** @type {import('../components/eventseries/types').GoalType} */
  let type;
  /** @type {import('../components/eventseries/types').GoalParamsType} */
  let params;
  const typeIdentifer = String(rawGoal.identifer);
  if (typeIdentifer.indexOf("ByAmount") > -1) {
    type = "byAmount";
    if (!rawGoal.detail?.amount || !rawGoal.detail?.requiredAmount)
      return null;
    params = {
      eventsAmount: parseInt(rawGoal.detail?.amount),
      requiredEventsAmount: parseInt(rawGoal.detail?.requiredAmount),
    };
  } else if (typeIdentifer.indexOf("ByPercent") > -1) {
    type = "byPercent";
    if (!rawGoal.detail?.percent) return null;
    params = {
      percent: parseFloat(
        (parseFloat(rawGoal.detail?.percent) * 100).toFixed(2)
      ),
    };
  } else if (typeIdentifer.indexOf("SpecificFLOATs") > -1) {
    type = "bySpecifics";
    if (!rawGoal.detail?.floats || !rawGoal.detail?.floats.length)
      return null;
    params = {
      events: rawGoal.detail?.floats,
    };
  } else {
    return null;
  }

  return {
    type,
    points: parseInt(rawGoal.points),
    status: rawGoal.status.rawValue,
    params,
  };
}

export const getTreasuryData = async (acct, seriesId) => {
  const raw = await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetTreasuryData, addressMap),
    (arg, t) => [
      arg(acct, t.Address),
      arg(seriesId, t.UInt64)
    ],
    null
  )
  if (!raw) return null
  return parseRawTreasuryData(raw)
}

/**
 * @return {import('../components/eventseries/types').TreasuryData}
 */
function parseRawTreasuryData (rawdata) {
  /** @type {{identifier: string , balance: string}[]} */
  const balances = []
  /** @type {{identifier: string , ids: [string]}[]} */
  const ids = []
  for (const key in rawdata.tokenBalances) {
    balances.push({ identifier: key, balance: rawdata.tokenBalances[key] })
  }
  for (const key in rawdata.collectionIDs) {
    ids.push({ identifier: key, ids: rawdata.collectionIDs[key] })
  }
  return {
    tokenBalances: balances,
    collectionIDs: ids
  }
}


/**
 * @return {import('../components/eventseries/types').StrategyDetail}
 */
function parseStrategyDetail (rawdata) {
  const strategyMode = String(rawdata.detail.strategyIdentifier).indexOf('ClaimingQueue') > -1 ? 'queueStrategy' : 'raffleStrategy'
  const strategyStatusMap = {
    '0': 'preparing',
    '1': 'opening',
    '2': 'claimable',
    '3': 'closed'
  }
  const status = rawdata.detail.status || {}
  const deliveryTypeMap = {
    '0': 'ftIdenticalAmount',
    '1': 'ftRandomAmount',
    '2': 'nft'
  }
  const deliveryMode = deliveryTypeMap[status.delivery.type?.rawValue]
  return {
    index: parseInt(rawdata.index),
    strategyMode,
    strategyData: {
      consumable: status.consumable,
      threshold: parseInt(status.threshold),
      openingEnding: rawdata.detail.strategyData.ending['1'],
      claimableEnding: rawdata.detail.strategyData.ending['2'],
      minValid: strategyMode === 'raffleStrategy' ? rawdata.detail.strategyData.minimiumValid : undefined,
      valid: strategyMode === 'raffleStrategy' ? rawdata.detail.strategyData.valid : undefined,
      winners: strategyMode === 'raffleStrategy' ? rawdata.detail.strategyData.winners : undefined,
    },
    currentState: strategyStatusMap[status?.currentState?.rawValue],
    deliveryMode,
    deliveryStatus: {
      deliveryTokenIdentifier: status.delivery.deliveryTokenType.typeID,
      // status
      maxClaimableShares: parseInt(status.delivery.maxClaimableShares),
      claimedShares: parseInt(status.delivery.claimedShares),
      restAmount: status.delivery.restAmount,
      oneShareAmount: status.delivery.oneShareAmount,
      totalAmount: status.delivery.totalAmount,
    },
    userStatus: rawdata.userAddress ? {
      eligible: rawdata.userInfo.eligible,
      claimable: rawdata.userInfo.claimable,
      claimed: rawdata.userInfo.claimed
    }: null
  }
}

/**
 * @return {Promise<import('../components/eventseries/types').StrategyQueryResult>}
 */
export const getSeriesStrategies = async (acct, seriesId, includingAvailables = false, user = undefined) => {
  const raw = await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetSeriesStrategies, addressMap),
    (arg, t) => [
      arg(acct, t.Address),
      arg(seriesId, t.UInt64),
      arg(includingAvailables, t.Bool),
      arg(user ?? null, t.Optional(t.Address))
    ],
    null
  )
  if (!raw) return null
  return {
    available: raw.available && parseRawTreasuryData(raw.available),
    strategies: raw.strategies.map(one => parseStrategyDetail(one)),
    userTotalScore: raw.userTotalScore,
    userConsumableScore: raw.userConsumableScore,
  }
}

// ***********************
// ** Achievement Board **
// ***********************

/**
 * check if you have achievement board
 * 
 * @param {string} acct
 */
export const hasAchievementBoard = async (acct) => {
  return await generalQuery(
    cadence.replaceImportAddresses(cadence.scHasAchievementBoard, addressMap),
    (arg, t) => [
      arg(acct, t.Address)
    ],
    false
  )
}


/**
 * get records
 * 
 * @param {string} acct
 * @param {string} host
 * @param {number} seriesIds
 */
export const getAchievementRecords = async (acct, host, seriesIds) => {
  return await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetAchievementRecords, addressMap),
    (arg, t) => [
      arg(acct, t.Address),
      arg(host, t.Address),
      arg(seriesIds, t.Array(t.UInt64))
    ],
    []
  )
}

/**
 * get and check goals
 * 
 * @param {string} acct
 * @param {string} host
 * @param {number} seriesId
 * @return {Promise<import('../components/eventseries/types').EventSeriesUserStatus>}
 */
export const getAndCheckEventSeriesGoals = async (acct, host, seriesId) => {
  const raw = await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetAndCheckEventSeriesGoals, addressMap),
    (arg, t) => [
      arg(acct, t.Address),
      arg(host, t.Address),
      arg(seriesId, t.UInt64)
    ],
    {}
  )
  if (!raw) return null
  return {
    goals: raw.goals.map(one => parseRawGoalData(one)).filter(one => !!one),
    owned: raw.owned,
    totalScore: parseInt(raw.totalScore) ?? 0,
    consumableScore: parseInt(raw.consumableScore) ?? 0,
  }
}

/**
 * @param {string} acct
 * @param {string[]} paths
 * @returns {Promise<import('../components/eventseries/types').TokenBalance[]>}
 */
export const getTokenBalances = async (acct, paths) => {
  return await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetBalances, addressMap),
    (arg, t) => [
      arg(acct, t.Address),
      arg(paths, t.Array(t.String))
    ],
    []
  )
}

/**
 * @param {string} acct 
 * @returns {Promise<import('../components/eventseries/types').CollectionInfo[]>}
 */
export const getCollectionsNotEmpty = async (acct) => {
  return await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetCollectionsNotEmpty, addressMap),
    (arg, t) => [
      arg(acct, t.Address)
    ],
    []
  )
}

/**
 * @returns {Promise<import('../components/eventseries/types').CollectionInfo[]>}
 */
export const getCollections = async (identifer) => {
  return await generalQuery(
    cadence.replaceImportAddresses(cadence.scGetCollections, addressMap),
    (arg, t) => [
      arg(identifer ?? null, t.Optional(t.String)),
    ],
    []
  )
}