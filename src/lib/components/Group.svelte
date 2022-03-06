<script>
  import { user } from "$lib/flow/stores";

  export let name = '';
  export let imagePreviewSrc = '';
  export let description = '';
  export let preview = false;
</script>

{#if preview}
  <article class="preview">
    <div class="img-container">
      <img src={imagePreviewSrc} alt="group" />
    </div>
    <div>
      <h4>{name}</h4>
      <p>{description}</p>
    </div>
  </article>
{:else}
  <article class="nopreview">
    <div class="img-container">
      <img src={imagePreviewSrc} alt="group" />
    </div>
    <div class="details">
      <h4>{name}</h4>
      <p>{description}</p>
    </div>
    <div class="actions">
      <a href="/{$user?.addr}/group/{name}" role="button">View</a>
      <button class="outline red">Delete</button>
    </div>
  </article>
{/if}

<style>
  .preview, .nopreview {
    padding: 50px;
    margin-bottom: 15px;
    align-items: center;
    display: flex;
    justify-content: space-between;
    
  }

  .preview img {
    margin-right: 50px;
  }
  
  .img-container {
    min-width: 200px;
  }

  .actions {
    margin-left: 15px;
  }

  a {
    width: 100px;
  }

  button {
    margin: 10px 0px;
  }

  img {
    max-width: 200px;
    max-height: 100px;
  }

  h4, p {
    margin: 0;
  }

  @media screen and (max-width: 767px) {
    .preview, .nopreview {
      flex-direction: column;
    }
    .preview img, .nopreview img {
      margin-right: 0px;
      margin-bottom: 15px;
    }
    .nopreview p {
      margin-bottom: 15px;
    }

    .nopreview h4 {
      text-align: center;
    }

    .actions {
      display: flex;
      align-items: center;
    }
    .actions a, .actions button {
      width: 100px;
      height: 50px;
      margin: 0px 10px;
    }
  }
</style>