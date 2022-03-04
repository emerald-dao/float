<script>
  import { user } from "$lib/flow/stores";

  export let name = '';
  export let imagePreviewSrc = '';
  export let description = '';
  export let preview = false;
</script>

{#if preview}
  <article class="grid preview">
    <img src={imagePreviewSrc} alt="group" />
    <div>
      <h4>{name}</h4>
      <p>{description}</p>
    </div>
  </article>
{:else}
  <article class="grid nopreview">
    <img src={imagePreviewSrc} alt="group" />
    <div>
      <h4>{name}</h4>
      <p>{description}</p>
    </div>
    <div>
      <a href="/{$user?.addr}/group/{name}" role="button">View</a>
      <button class="outline red">Delete</button>
    </div>
  </article>
{/if}

<style>
  .grid {
    padding: 50px;
    margin-bottom: 15px;
    align-items: center;
  }
  .preview {
    grid-template-columns: 200px 1fr;
  }
  .nopreview {
    grid-template-columns: 200px 1fr 100px;
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
</style>