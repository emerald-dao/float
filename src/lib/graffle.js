// import { HubConnectionBuilder } from '@microsoft/signalr'
// export default function GraffleSDK() {

//   let negotiateResult;
//   const projectID = import.meta.env.VITE_GRAFFLE_TESTNET_PROJECT_ID;

//   const negotiate = async () => {

//     const authHeader = {
//       "graffle-api-key": import.meta.env.VITE_GRAFFLE_TESTNET_API_KEY,
//       "Content-Type": "application/x-www-form-urlencoded"
//     }
//     const url = import.meta.env.VITE_GRAFFLE_TESTNET_API_URL;

//     negotiateResult = await fetch(url, { headers: authHeader, method: 'POST', body: {}});
//     negotiateResult = await negotiateResult.json(); 
//     return negotiateResult
//   };

//   this.stream = async (streamCallback) => {
//     let res = await negotiate();
//     const connection = new HubConnectionBuilder()
//       .withUrl(res.url, {
//         accessTokenFactory: () => res.accessToken,
//       })
//       .withAutomaticReconnect()
//       .build();

//     if (connection) {
//       connection.start()
//         .then((result) => {
//           console.log("1st Parse: "+projectID)
//           connection.on(projectID, (message) => {
//             var parsedMessage = JSON.parse(message);
//             //console.log("Parsing Message for: "+projectID)
//             streamCallback(parsedMessage); 
//           });
//         });
//     }
//     return connection;
//   };
// }