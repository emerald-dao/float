<script>
  import LibLoader from "$lib/components/LibLoader.svelte";
  
  export let data;
  export let image;

  let qrCodeDiv;
  let QRCode;

  function onLoaded() {

    console.log('QR CODE:', data);

    QRCode = new QRCodeStyling({
        width: 200,
        height: 200,
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
          color: "#11191f",
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

<div title="Click to download SVG" bind:this={qrCodeDiv} on:click="{onClick}"></div>

<style>
  div { 
    margin: 1rem 0 1rem 0; 
    border-radius:4px; 
    cursor:pointer;
  }
</style>