import MetadataViews from "./MetadataViews.cdc"
import NFTCatalog from "./NFTCatalog.cdc"

// NFTRetrieval
//
// A helper contract to get NFT's in a users account
// leveraging the NFTCatalog Smart Contract

access(all) contract NFTRetrieval {
    
    access(all) fun getRecommendedViewsTypes(version: String) : [Type] {
        switch version {
            case "v1":
                return [
                        Type<MetadataViews.Display>(), 
                        Type<MetadataViews.ExternalURL>(), 
                        Type<MetadataViews.NFTCollectionData>(), 
                        Type<MetadataViews.NFTCollectionDisplay>(),
                        Type<MetadataViews.Royalties>()
                ]
            default:
                panic("Version not supported")
        } 
        return []
    }

    access(all) fun getNFTIDsFromCap(collectionIdentifier: String, collectionCap : Capability<&AnyResource{MetadataViews.ResolverCollection}>) : [UInt64] {
        pre {
            NFTCatalog.getCatalog()[collectionIdentifier] != nil : "Invalid collection identifier"
        }
        let catalog = NFTCatalog.getCatalog()
        let value = catalog[collectionIdentifier]!

        // Check if we have multiple collections for the NFT type...
        let hasMultipleCollections = self.hasMultipleCollections(nftTypeIdentifier : value.nftType.identifier)

        if collectionCap.check() {
            let collectionRef = collectionCap.borrow()!
            if !hasMultipleCollections {
                return collectionRef.getIDs()
            }
            var ids : [UInt64] = []
            
            for id in collectionRef.getIDs() {
                let nftResolver = collectionRef.borrowViewResolver(id: id)
                let nftViews = MetadataViews.getNFTView(id: id, viewResolver: nftResolver)
                if nftViews.display!.name == value.collectionDisplay.name {
                    ids.append(id)
                } 
            }
            return ids
        }
        
        return []
    }

    access(all) fun getNFTCountFromCap(collectionIdentifier: String, collectionCap : Capability<&AnyResource{MetadataViews.ResolverCollection}>) : UInt64 {
        pre {
            NFTCatalog.getCatalog()[collectionIdentifier] != nil : "Invalid collection identifier"
        }
        let catalog = NFTCatalog.getCatalog()
        let value = catalog[collectionIdentifier]!
        // Check if we have multiple collections for the NFT type...
        let hasMultipleCollections = self.hasMultipleCollections(nftTypeIdentifier : value.nftType.identifier)

        if collectionCap.check() {
            let collectionRef = collectionCap.borrow()!
            if !hasMultipleCollections {
                return UInt64(collectionRef.getIDs().length)
            }
            var count : UInt64 = 0
            for id in collectionRef.getIDs() {
                let nftResolver = collectionRef.borrowViewResolver(id: id)
                let nftViews = MetadataViews.getNFTView(id: id, viewResolver: nftResolver)
                if nftViews.display!.name == value.collectionDisplay.name {
                    count = count + 1
                }   
            }
            return count
        }
        return 0 
    }

    access(all) fun getNFTViewsFromCap(collectionIdentifier: String, collectionCap : Capability<&AnyResource{MetadataViews.ResolverCollection}>) : [MetadataViews.NFTView] {
        pre {
            NFTCatalog.getCatalog()[collectionIdentifier] != nil : "Invalid collection identifier"
        }
        let catalog = NFTCatalog.getCatalog()
        let items : [MetadataViews.NFTView] = []
        let value = catalog[collectionIdentifier]!

        // Check if we have multiple collections for the NFT type...
        let hasMultipleCollections = self.hasMultipleCollections(nftTypeIdentifier : value.nftType.identifier)
        
        if collectionCap.check() {
            let collectionRef = collectionCap.borrow()!
            for id in collectionRef.getIDs() {
                let nftResolver = collectionRef.borrowViewResolver(id: id)
                let nftViews = MetadataViews.getNFTView(id: id, viewResolver: nftResolver)
                if !hasMultipleCollections {
                    items.append(nftViews)
                } else if nftViews.display!.name == value.collectionDisplay.name {
                    items.append(nftViews)
                }
            
            }
        }

        return items
    }

    access(all) fun getNFTViewsFromIDs(collectionIdentifier : String, ids: [UInt64], collectionCap : Capability<&AnyResource{MetadataViews.ResolverCollection}>) : [MetadataViews.NFTView] {
        pre {
            NFTCatalog.getCatalog()[collectionIdentifier] != nil : "Invalid collection identifier"
        }

        let catalog = NFTCatalog.getCatalog()
        let items : [MetadataViews.NFTView] = []
        let value = catalog[collectionIdentifier]!

        // Check if we have multiple collections for the NFT type...
        let hasMultipleCollections = self.hasMultipleCollections(nftTypeIdentifier : value.nftType.identifier)

         if collectionCap.check() {
            let collectionRef = collectionCap.borrow()!
            for id in ids {
                if !collectionRef.getIDs().contains(id) {
                    continue
                }
                let nftResolver = collectionRef.borrowViewResolver(id: id)
                let nftViews = MetadataViews.getNFTView(id: id, viewResolver: nftResolver)
                if !hasMultipleCollections {
                    items.append(nftViews)
                } else if nftViews.display!.name == value.collectionDisplay.name {
                    items.append(nftViews)
                }
            
            }
        }


        return items
    }

    access(contract) fun hasMultipleCollections(nftTypeIdentifier : String): Bool {
        let typeCollections = NFTCatalog.getCollectionsForType(nftTypeIdentifier: nftTypeIdentifier)!
        var numberOfCollections = 0
        for identifier in typeCollections.keys {
            let existence = typeCollections[identifier]!
            if existence {
                numberOfCollections = numberOfCollections + 1
            }
            if numberOfCollections > 1 {
                return true
            }
        }
        return false
    }

    //LEGACY - DO NOT USE
    access(all) struct BaseNFTViewsV1 {
        access(all) let id: UInt64
        access(all) let display: MetadataViews.Display?
        access(all) let externalURL: MetadataViews.ExternalURL?
        access(all) let collectionData: MetadataViews.NFTCollectionData?
        access(all) let collectionDisplay: MetadataViews.NFTCollectionDisplay?
        access(all) let royalties: MetadataViews.Royalties?

        init(
            id : UInt64,
            display : MetadataViews.Display?,
            externalURL : MetadataViews.ExternalURL?,
            collectionData : MetadataViews.NFTCollectionData?,
            collectionDisplay : MetadataViews.NFTCollectionDisplay?,
            royalties : MetadataViews.Royalties?
        ) {
            self.id = id
            self.display = display
            self.externalURL = externalURL
            self.collectionData = collectionData
            self.collectionDisplay = collectionDisplay
            self.royalties = royalties
        }
    }

    init() {}

}