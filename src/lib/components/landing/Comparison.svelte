<script>
    const differences = [
        {
            poap: {
                title: "Off chain components.",
                description:
                    "POAP events are off-chain and stored in a database. It does not completely utilize the decentralized nature of the blockchain.",
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
        {
            poap: {
                title: "Cannot pause transferring.",
                description:
                    "As an event owner, you cannot prevent users from transferring POAPs to each other. This means some users may contain POAPs for not even attending an event.",
            },
            float: {
                title: "Can pause transfers.",
                description:
                    "You can toggle on/off transfers (and claiming) at any point in time to ensure they are not given to users who did not attend.",
            },
        },
        {
            poap: {
                title: "Can take away user POAPs.",
                description:
                    "POAP retains the power to take away users' POAPs. Check out <a href='https://mirror.xyz/metamess.eth/SY7e-ouQ33Aaj6FHF0TgjC-gYmKfTYL66oA2j2XflbY' target='_blank'>this tweet</a> by an angry user.",
            },
            float: {
                title: "True ownership.",
                description:
                    "Due to FLOAT being entirely on chain, and the resource oriented nature of the Flow blockchain, users' FLOATs are truly owned by the user.",
            },
        },
    ];
</script>

<div class="comparison home-page-padding">
    <h2>POAP vs. FLOAT</h2>
    <div class="pictures">
        <img src="/poapad.png" alt="POAP ad" />
        <img src="/freakizoid.png" alt="FLOAT ad" />
    </div>
    {#each differences as difference}
        <div class="row">
            <div class="poap">
                <strong>&#10060; {difference.poap.title}</strong>
                {@html difference.poap.description}
            </div>
            <div class="float">
                <strong>&#9989; {difference.float.title}</strong>
                {@html difference.float.description}
            </div>
        </div>
    {/each}
</div>

<style>
    .comparison {
        background-color: var(--contrast);
        padding-top: 3rem;
        padding-bottom: 3rem;
    }

    .poap {
        background-color: var(--contrast-inverse);
        border-top-left-radius: 0.4rem;
        border-bottom-left-radius: 0.4rem;
    }

    .float {
        background-color: rgb(133, 236, 221);
        color: rgb(43, 43, 43);
        border-top-right-radius: 0.4rem;
        border-bottom-right-radius: 0.4rem;
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
        object-fit: cover;
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
