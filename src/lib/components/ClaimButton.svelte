<script>
  export let floatEvent;
  export let hasClaimed;
  import { floatClaimedStatus, floatClaimingInProgress, user } from "$lib/flow/stores";
  import { claimFLOAT } from "$lib/flow/actions.js";
  import Countdown from "$lib/components/common/Countdown.svelte";

  const secretModule = floatEvent?.verifiers["A.0afe396ebc8eee65.FLOATVerifiers.Secret"];
  const limitedModule = floatEvent?.verifiers["A.0afe396ebc8eee65.FLOATVerifiers.Limited"];
  const timelockModule = floatEvent?.verifiers["A.0afe396ebc8eee65.FLOATVerifiers.Timelock"];
  const multipleSecretModule = floatEvent?.verifiers["A.0afe396ebc8eee65.FLOATVerifiers.MultipleSecret"];

  let claimCode = "";
  $: currentUnixTime = +new Date() / 1000;
</script>

{#if hasClaimed}
  <button class="secondary outline" disabled>
    ✓ You already claimed this FLOAT.
  </button>
{:else if floatEvent?.claimable}
  {#if (secretModule || multipleSecretModule)}
    <label for="claimCode">
      Enter the claim code below (<i>case sensitive</i>).
      <input
        type="text"
        name="claimCode"
        bind:value={claimCode}
        placeholder="secret code"
      />
    </label>
  {/if}

  {#if (secretModule || multipleSecretModule) && claimCode === ""}
    <button class="secondary outline" disabled>
      You must enter a secret code.
    </button>
  {:else if limitedModule && limitedModule.capacity <= floatEvent?.totalSupply}
    <button class="secondary outline" disabled>
      This FLOAT is no longer available.<br /> All
      <span class="emphasis">
        {floatEvent?.totalSupply}/{limitedModule.capacity}
      </span> have been claimed.
    </button>
  {:else if timelockModule && timelockModule.dateStart > currentUnixTime}
    <button class="secondary outline" disabled>
      This FLOAT Event has not started yet.<br />
      Starting in
      <span class="emphasis">
        <Countdown unix={timelockModule.dateStart} />
      </span>
    </button>
  {:else if timelockModule && timelockModule.dateEnding < currentUnixTime}
    <button class="secondary outline" disabled>
      This FLOAT is no longer available.<br />This event has ended.
    </button>
  {:else if $floatClaimingInProgress}
    <button aria-busy="true" disabled>Claiming FLOAT</button>
  {:else if $floatClaimedStatus.success}
    <a
      role="button"
      class="d-block"
      href="/{$user?.addr}"
      style="display:block"
      >FLOAT claimed successfully!
    </a>
  {:else if !$floatClaimedStatus.success && $floatClaimedStatus.error}
    <button class="error" disabled>
      {$floatClaimedStatus.error}
    </button>
  {:else}
    <button
      disabled={$floatClaimingInProgress}
      on:click={() =>
        claimFLOAT(floatEvent?.eventId, floatEvent?.host, claimCode)}
      >Claim this FLOAT
    </button>
  {/if}
{:else}
  <button class="secondary outline" disabled>
    This FLOAT is not claimable.<br />The host has done this either to distribute it manually or halt claiming.
  </button>
{/if}