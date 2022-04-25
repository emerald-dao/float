// MADE BY: Bohao Tang

// This contract is for FLOAT Events Book

import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FungibleToken from "../core-contracts/FungibleToken.cdc"
import FLOAT from "../float/FLOAT.cdc"

pub contract FLOATEventsBook {

    /**    ___  ____ ___ _  _ ____
       *   |__] |__|  |  |__| [__
        *  |    |  |  |  |  | ___]
         *************************/
    
    pub let FLOATEventsBookshelfStoragePath: StoragePath
    pub let FLOATEventsBookshelfPublicPath: PublicPath
    pub let FLOATAchievementsStoragePath: StoragePath
    pub let FLOATAchievementsPublicPath: PublicPath

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/
    
    // emitted when contract initialized
    pub event ContractInitialized()

    /**    ____ ___ ____ ___ ____
       *   [__   |  |__|  |  |___
        *  ___]  |  |  |  |  |___
         ************************/
    
    // total event books amount
    pub var totalEventsBooks: UInt64

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // ---- data For Curators ----
    
    pub struct EventIdentifier {
        pub let creator: Address
        pub let id: UInt64

        init(_ address: Address, _ id: UInt64) {
            self.creator = address
            self.id = id
        }
    }

    pub struct interface EventSlot {
        pub fun getIdentifier(): EventIdentifier?
    }

    pub struct interface WritableEventSlot {
        access(account) fun setIdentifier (_ identifier: EventIdentifier)
    }

    pub struct RequiredEventSlot: EventSlot {
        pub let identifier: EventIdentifier

        init(_ identifier: EventIdentifier) {
            self.identifier = identifier
        }

        pub fun getIdentifier(): EventIdentifier? {
            return self.identifier
        }
    }

    pub struct OptionalEventSlot: EventSlot, WritableEventSlot {
        pub var identifier: EventIdentifier?

        init(_ identifier: EventIdentifier?) {
            self.identifier = identifier
        }
        access(account) fun setIdentifier (_ identifier: EventIdentifier) {
            self.identifier = identifier
        }
        pub fun getIdentifier(): EventIdentifier? {
            return self.identifier
        }
    }

    pub struct EmptyEventSlot: EventSlot, WritableEventSlot {
        pub var identifier: EventIdentifier?

        init() {
            self.identifier = nil
        }
        access(account) fun setIdentifier (_ identifier: EventIdentifier) {
            self.identifier = identifier
        }
        pub fun getIdentifier(): EventIdentifier? {
            return self.identifier
        }
    }
    
    pub resource EventsBook {
        access(account) let slots: [{EventSlot}]

        init() {
            self.slots = []
        }

    }

    pub resource EventsBookshelf {

        init() {

        }
    }

    pub resource Treasury {

        init() {

        }
    }

    // ---- data For Endusers ----

    pub resource Achievements {

        init() {

        }
    }

    // ---- contract methods ----

    pub fun createEventsBookshelf(): @EventsBookshelf {
        return <- create EventsBookshelf()
    }

    pub fun createAchievements(): @Achievements {
        return <- create Achievements()
    }

    init() {
        self.totalEventsBooks = 0

        self.FLOATEventsBookshelfStoragePath = /storage/FLOATEventsBookshelfStoragePath
        self.FLOATEventsBookshelfPublicPath = /public/FLOATEventsBookshelfPublicPath
        self.FLOATAchievementsStoragePath = /storage/FLOATAchievementsStoragePath
        self.FLOATAchievementsPublicPath = /public/FLOATAchievementsPublicPath

        emit ContractInitialized()
    }
}
