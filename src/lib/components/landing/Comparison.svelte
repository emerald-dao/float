<script>
    const differences = [
        {
            poap: {
                title: "Off chain.",
                description:
                    "POAP is an off-chain platform and does not utilize the decentralized nature of the blockchain.",
            },
            float: {
                title: "On chain.",
                description:
                    "FLOAT is an on-chain platform. In fact, there is no database or backend whatsoever.",
            },
        },
        {
            poap: {
                title: "Whitelisted.",
                description:
                    "To make an event on POAP, you must first get approval by the platform.",
            },
            float: {
                title: "Open for all.",
                description:
                    "Anybody can make a FLOAT event. You do not have to pre-register.",
            },
        },
        {
            poap: {
                title: "Not integrable.",
                description:
                    "Due to its off-chain nature, POAPs cannot be integrated with other 3rd party DApps in transactions.",
            },
            float: {
                title: "Integrable.",
                description:
                    "Plug numerous FLOAT interactions into your own transactions, such as depositing a FLOAT to a user who mints your NFT.",
            },
        },
    ];
</script>

<div class="comparison">
    <h2>POAP vs. FLOAT</h2>
    <div class="pictures">
        <img src="/poapad.png" alt="POAP ad" />
        <img src="/floatad.png" alt="FLOAT ad" />
    </div>
    {#each differences as difference}
        <div class="row">
            <div class="poap">
                <strong>{difference.poap.title}</strong>
                {difference.poap.description}
            </div>
            <div class="float">
                <strong>{difference.float.title}</strong>
                {difference.float.description}
            </div>
        </div>
    {/each}
</div>

<style>
    .comparison {
        background-color: var(--contrast);
        padding: 3rem 4rem;
    }

    .poap {
        background-color: var(--contrast-inverse);
        border-top-left-radius: 0.4rem;
        border-bottom-left-radius: 0.4rem;
    }

    .float {
        background-color: #35d9ba;
        color: var(--contrast);
    }

    h2 {
        font-size: 4.3rem;
        font-weight: 600;
        line-height: 120%;
        margin-bottom: 2.4rem;
        color: var(--contrast-inverse);
    }

    .pictures {
        display: flex;
    }

    .pictures > img {
        width: 50%;
        border-radius: 0px;
    }

    .pictures > img:nth-child(1) {
        border-top-left-radius: 0.4rem;
    }

    .pictures > img:nth-child(2) {
        border-top-right-radius: 0.4rem;
    }

    .row {
        display: flex;
        position: relative;
        margin-top: 10px;
    }

    .row > div {
        width: 50%;
        padding: 1.4rem 1.2rem;
        gap: 0.8rem;
        box-sizing: border-box;
    }
</style>
