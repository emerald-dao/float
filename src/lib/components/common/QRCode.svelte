<script>
  import LibLoader from "$lib/components/LibLoader.svelte";
  
  export let data;
  export let image;

  let qrCodeDiv;
  let QRCode;

  function onLoaded() {

    QRCode = new QRCodeStyling({
        width: 250,
        height: 250,
        type: "svg",
        data: data,
        image: image ?  "https://ipfs.infura.io/ipfs/" + image : "/emeraldCityLogo.png",
        qrOptions: {
          typeNumber: 0,
          mode: "Byte",
          errorCorrectionLevel: "Q"
        },
        dotsOptions: {
          color: "#38e8c6",
          type: "extra-rounded"
        },
        backgroundOptions: {
          color: "#111",
        },
        imageOptions: {
            imageSize: 0.6,
            crossOrigin: "anonymous",
            margin: 8
        },
        downloadOptions: {
          name: "QRCode",
        }
    });
    QRCode.append(qrCodeDiv)
  }

  function onClick() {
    QRCode.download({ name: "qrcode", extension: "svg" });
  }  
  
</script>

<LibLoader
  url="https://unpkg.com/qr-code-styling@1.5.0/lib/qr-code-styling.js"
  on:loaded="{onLoaded}"    
  uniqueId={+new Date()}
/>

<div bind:this={qrCodeDiv}></div>
<button on:click="{onClick}">Download QRCode</button>

<style>
  div { margin: 1rem 0 1rem 0 }
  button { 
    margin: 0.5rem auto ;
    max-width: 250px;
  } 
</style>