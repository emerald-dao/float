<script>
  export let floatEvent;
  export let hasClaimed;
  export let flowTokenCost;
  import {
    floatClaimedStatus,
    floatClaimingInProgress,
    user,
  } from "$lib/flow/stores";
  import { claimFLOAT, claimFLOATv2 } from "$lib/flow/actions.js";
  import Countdown from "$lib/components/common/Countdown.svelte";
  import { verifiersIdentifier } from "$lib/flow/config";
  import { signWithClaimCode } from "$lib/flow/utils";

  const secretModule =
    floatEvent?.verifiers[`${verifiersIdentifier}.FLOATVerifiers.Secret`];
  const secretv2Module =
    floatEvent?.verifiers[`${verifiersIdentifier}.FLOATVerifiers.SecretV2`];
  const limitedModule =
    floatEvent?.verifiers[`${verifiersIdentifier}.FLOATVerifiers.Limited`];
  const timelockModule =
    floatEvent?.verifiers[`${verifiersIdentifier}.FLOATVerifiers.Timelock`];
  const multipleSecretModule =
    floatEvent?.verifiers[
      `${verifiersIdentifier}.FLOATVerifiers.MultipleSecret`
    ];

  let claimCode = "";
  let confirmed = false;
  $: currentUnixTime = +new Date() / 1000;

  function claimTheFloat() {
    const timeOfUpdate = floatEvent.dateCreated;
    if (currentUnixTime > timeOfUpdate) {
      const secretSig = signWithClaimCode(claimCode);
      claimFLOATv2(floatEvent?.eventId, floatEvent?.host, secretSig);
    } else {
      claimFLOAT(floatEvent?.eventId, floatEvent?.host, claimCode);
    }
  }
</script>

{#if hasClaimed}
  <button class="secondary outline" disabled>
    ✓ You already claimed this FLOAT.
  </button>
{:else if floatEvent?.claimable}
  {#if limitedModule && limitedModule[0].capacity <= floatEvent?.totalSupply}
    <button class="secondary outline" disabled>
      This FLOAT is no longer available.<br /> All
      <span class="emphasis">
        {floatEvent?.totalSupply}/{limitedModule[0].capacity}
      </span> have been claimed.
    </button>
  {:else if timelockModule && timelockModule[0].dateStart > currentUnixTime}
    <button class="secondary outline" disabled>
      This FLOAT Event has not started yet.<br />
      Starting in
      <span class="emphasis">
        <Countdown unix={timelockModule[0].dateStart} />
      </span>
    </button>
  {:else if multipleSecretModule && Object.keys(multipleSecretModule[0].secrets).length === 0}
    <button class="secondary outline" disabled>
      This FLOAT Event has run out of secret codes.
    </button>
  {:else if timelockModule && timelockModule[0].dateEnding < currentUnixTime}
    <button class="secondary outline" disabled>
      This FLOAT is no longer available.<br />This event has ended.
    </button>
  {:else if flowTokenCost && !confirmed}
    <button class="important" on:click={() => (confirmed = true)}>
      This costs {parseFloat(flowTokenCost).toFixed(2)} FlowToken. Click to confim.
    </button>
  {:else if $floatClaimingInProgress}
    <button aria-busy="true" disabled>Claiming FLOAT</button>
  {:else if $floatClaimedStatus.success}
    <a
      role="button"
      class="d-block"
      href="/{$user?.addr}/?tab=floats"
      style="display:block"
      >FLOAT claimed successfully!
    </a>
  {:else if !$floatClaimedStatus.success && $floatClaimedStatus.error}
    <button class="error" disabled>
      {$floatClaimedStatus.error}
    </button>
  {:else}
    {#if secretModule || secretv2Module || multipleSecretModule}
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
    <button
      class={(secretModule || secretv2Module || multipleSecretModule) &&
      claimCode == ""
        ? "secondary outline"
        : null}
      disabled={$floatClaimingInProgress ||
        ((secretModule || secretv2Module || multipleSecretModule) &&
          claimCode == "")}
      on:click={claimTheFloat}
      >{(secretModule || secretv2Module || multipleSecretModule) &&
      claimCode == ""
        ? "You must input a secret phrase"
        : flowTokenCost
        ? "Purchase this FLOAT"
        : "Claim this FLOAT"}
    </button>
  {/if}
{:else}
  <button class="secondary outline" disabled>
    This FLOAT is not claimable.<br />The host has done this either to
    distribute it manually or halt claiming.
  </button>
{/if}
