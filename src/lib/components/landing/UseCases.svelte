<script>
    const useCasesList = [
        {
            name: "Discord AMA",
            description:
                "Host an event on Discord and create an event for it. Have participants claim the FLOAT to represent their attendance.",
            image: "/discord-logo.png",
        },
        {
            name: "Twitter Space AMA",
            description:
                "Host a Twitter Space and create an event for it. Have participants claim the FLOAT to represent their attendance.",
            image: "/twitter-logo.webp",
        },
        {
            name: "Giveaways",
            description:
                "Have participants claim a FLOAT to enter the giveaway. Then, in Discord using the Emerald bot, use the /randomfloats command to pick a winner.",
            image: "/favicon.png",
        },
        {
            name: "Giveaways",
            description:
                "Have participants claim a FLOAT to enter the giveaway. Then, in Discord using the Emerald bot, use the /randomfloats command to pick a winner.",
            image: "/favicon.png",
        },
    ];
</script>

<div class="use-cases">
    <h2>Use cases</h2>
    <div class="use-cases-list">
        {#each useCasesList as useCase}
            <div>
                <h3>{useCase.name}</h3>
                <p>{useCase.description}</p>
                <img src={useCase.image} alt="logo" />
            </div>
        {/each}
    </div>
</div>

<style>
    h3 {
        font-size: 1.45rem;
        font-weight: 600;
        line-height: 1.75rem;
        margin-bottom: 1rem;
    }
    .use-cases {
        padding: 0 2rem;
    }

    h2 {
        font-size: 4.3rem;
        font-weight: 600;
        line-height: 120%;
        margin-bottom: 2.4rem;
    }

    .use-cases-list {
        display: flex;
        flex-wrap: wrap;
        gap: 0.75rem;
    }

    .use-cases-list > div {
        position: relative;
        border-radius: 0.6rem;
        box-sizing: border-box;
        flex-basis: 30%;
        flex-grow: 1;
        padding: 1.3rem 1.2rem 4rem;
        background-color: var(--primary-hover);
        min-width: 300px;
    }

    .use-cases-list > div > p {
        letter-spacing: -0.01rem;
        line-height: 120%;
        margin-bottom: 1rem;
    }

    .use-cases-list > div > img {
        max-height: 50px;
        position: absolute;
        left: 1.2rem;
        bottom: 1.2rem;
    }
</style>
