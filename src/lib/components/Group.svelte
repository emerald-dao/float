<script>
  import { user } from "$lib/flow/stores";

  export let name = "";
  export let imagePreviewSrc = "";
  export let description = "";
</script>

<a href="/{$user?.addr}/group/{name}">
  <article class="preview">
    <div class="img-container">
      <img src={imagePreviewSrc} alt="group" />
    </div>
    <div class="details">
      <h4>{name}</h4>
      <p>{description}</p>
    </div>
  </article>
</a>

<style>
  .preview {
    padding: 50px 50px 50px 20px;
    margin-bottom: 15px;
    align-items: center;
    display: flex;
    justify-content: space-between;
  }

  .details {
    margin-left: 15px;
  }

  .img-container {
    min-width: 200px;
    display: flex;
    justify-content: center;
  }

  .img-container img {
    margin: 0px;
    padding: 0px;
    max-width: 200px;
    max-height: 100px;
  }

  .details p {
    /* color: var(--color); */
  }

  h4,
  p {
    margin: 0;
    text-decoration: none;
  }

  a {
    text-decoration: none;
  }

  @media screen and (max-width: 767px) {
    .preview {
      flex-direction: column;
    }
    .preview img {
      margin-right: 0px;
      margin-bottom: 15px;
    }
  }
</style>
