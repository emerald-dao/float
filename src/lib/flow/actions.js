import { browser } from '$app/env';
import { get } from 'svelte/store';

import * as fcl from "@samatech/onflow-fcl-esm";
import "./config";
import { user, txId, transactionStatus, transactionInProgress } from './stores';

if(browser) {
  // set Svelte $user store to currentUser, 
  // so other components can access it
  fcl.currentUser.subscribe(user.set, [])
}

// Lifecycle FCL Auth functions
export const unauthenticate = () => fcl.unauthenticate()
export const logIn = () => fcl.logIn()
export const signUp = () => fcl.signUp()


export const createFloat = async (draftFloat) => {

  /**
   * WE NEED TO VALIDATE THE DRAFT FLOAT
   * AND PARSE THE FIELDS AND GET THEM 
   * READY FOR THE TRANSACTION (i.e. turn them into the right arguments)
   */
  
  let floatObject = {};

  
  floatObject.type = draftFloat.claimable ? 0 : 1;
  floatObject.name = draftFloat.name;
  floatObject.description = draftFloat.description;
  floatObject.image = draftFloat.ipfsHash;
  floatObject.transferrable = draftFloat.transferrable;
  floatObject.secret = draftFloat.claimCode;
  floatObject.capacity = draftFloat.quantity;
  floatObject.timePeriod = +new Date(draftFloat.endTime) / 1000;


  // type: UInt8, name: String, description: String, image: String, transferrable: Bool, timePeriod: UFix64?, secret: String?, capacity: UInt64?

  let transactionId = false;
  initTransactionState()

  try {
    transactionId = await fcl.mutate({
      cadence: `
        import FLOAT from 0xFloat

        transaction(type: UInt8, name: String, description: String, image: String, transferrable: Bool, timePeriod: UFix64?, secret: String?, capacity: UInt64?) {

          let FLOATEvents: &FLOAT.FLOATEvents
        
          prepare(acct: AuthAccount) {
            self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                                ?? panic("Could not borrow the FLOATEvents from the signer.")
          }
        
          execute {
            var Timelock: FLOAT.Timelock? = nil
            var Secret: FLOAT.Secret? = nil
            var Limited: FLOAT.Limited? = nil
            
            if let timePeriod = timePeriod {
              Timelock = FLOAT.Timelock(_timePeriod: timePeriod)
            }
            
            if let secret = secret {
              Secret = FLOAT.Secret(_secretPhrase: secret)
            }
        
            if let capacity = capacity {
              Limited = FLOAT.Limited(_capacity: capacity)
            }
            
            self.FLOATEvents.createEvent(claimType: FLOAT.ClaimType(rawValue: type)!, timelock: Timelock, secret: Secret, limited: Limited, name: name, description: description, image: image, transferrable: transferrable, {})
            log("Started a new event.")
          }
        }
      `,
      args: (arg, t) => [
        arg(floatObject.type, t.UInt8),
        arg(floatObject.name, t.String),
        arg(floatObject.description, t.String),
        arg(floatObject.image, t.String),
        arg(floatObject.transferrable, t.Bool),
        arg(floatObject.secret, t.String),
        arg(floatObject.capacity, t.UInt64),
        arg(floatObject.timePeriod, t.UFix64),
      ],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 50
    })

    txId.set(transactionId);

    fcl.tx(transactionId).subscribe(res => {
      transactionStatus.set(res.status)
      if(res.status === 4) {
        setTimeout(() => transactionInProgress.set(false),2000)
      }
    })

  } catch (e) {
    transactionStatus.set(99)
    console.log(e)
  }
}

// // init account
// export const initAccount = async () => {

// }

// // EXAMPLES: send a transaction to get a user's profile
// export const sendQuery = async (addr) => {
//   let profileQueryResult = false;

//   try {
//     profileQueryResult = await fcl.query({
//       cadence: `
//         import Profile from 0xProfile
  
//         pub fun main(address: Address): Profile.ReadOnly? {
//           return Profile.read(address)
//         }
//       `,
//       args: (arg, t) => [arg(addr, t.Address)]
//     })
//     console.log(profileQueryResult)
//     profile.set(profileQueryResult);

//   } catch(e) {
//     console.log(e);
//   }
// }

// export const executeTransaction = async () => {
//   initTransactionState()
//   try {
//     const transactionId = await fcl.mutate({
//       cadence: `
//         import Profile from 0xProfile
  
//         transaction(name: String, color: String, info: String) {
//           prepare(account: AuthAccount) {
//             account
//               .borrow<&Profile.Base{Profile.Owner}>(from: Profile.privatePath)!
//               .setName(name)

//             account
//               .borrow<&Profile.Base{Profile.Owner}>(from: Profile.privatePath)!
//               .setInfo(info)

//             account
//               .borrow<&Profile.Base{Profile.Owner}>(from: Profile.privatePath)!
//               .setColor(color)
//           }
//         }
//       `,
//       args: (arg, t) => [
//         arg(get(profile).name, t.String),
//         arg(get(profile).color, t.String),
//         arg(get(profile).info, t.String),
//       ],
//       payer: fcl.authz,
//       proposer: fcl.authz,
//       authorizations: [fcl.authz],
//       limit: 50
//     })
//     fcl.tx(transactionId).subscribe(res => {
//       transactionStatus.set(res.status)
//       if(res.status === 4) {
//         setTimeout(() => transactionInProgress.set(false),2000)
//       }
//     })
//   } catch(e) {
//     console.log(e);
//     transactionStatus.set(99)
//   }
// }

function initTransactionState() {
  transactionInProgress.set(true);
  transactionStatus.set(-1);
}