import { NFTStorage } from 'nft.storage';
import { env as PublicEnv } from '$env/dynamic/public';

const NFT_STORAGE_TOKEN = PublicEnv.PUBLIC_NFT_STORAGE_KEY;

const client = new NFTStorage({ token: NFT_STORAGE_TOKEN });

const uploadToIPFS = async (file: File) => {
    try {
        return await client.storeBlob(file);
    } catch (error) {
        console.log(error);
        throw new Error('Error uploading image to IPFS');
    }
};

export default uploadToIPFS;
