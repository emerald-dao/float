import { HubConnectionBuilder } from "$lib/signalr";
import axios from "axios";

export default function GraffleSDK() {

  let negotiateResult;
  const projectID = import.meta.env.VITE_GRAFFLE_TESTNET_PROJECT_ID;
  const negotiate = async () => {

    const authHeader = {
      "graffle-api-key": import.meta.env.VITE_GRAFFLE_TESTNET_API_KEY,
      "Content-Type": "application/x-www-form-urlencoded"
    }
    const url = import.meta.env.VITE_GRAFFLE_TESTNET_API_URL;

    negotiateResult = await axios.post(url, {}, { headers: authHeader });
  };

  this.stream = async (streamCallback) => {
    await negotiate();
    const connection = new HubConnectionBuilder()
      .withUrl(negotiateResult.data.url, {
        accessTokenFactory: () => negotiateResult.data.accessToken,
      })
      .withAutomaticReconnect()
      .build();

    if (connection) {
      connection.start()
        .then((result) => {
          //console.log("1st Parse: "+projectID)
          connection.on(projectID, (message) => {
            var parsedMessage = JSON.parse(message);
            //console.log("Parsing Message for: "+projectID)
            streamCallback(parsedMessage);
          });
        });
    }
    return connection;
  };
}