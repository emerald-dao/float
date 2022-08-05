<script>
    const useCasesList = [
        {
            name: "Discord AMA",
            description:
                "Host an event on Discord and create an event for it. Have participants claim the FLOAT to represent their attendance.",
            image: "/discord.png",
            example: "https://floats.city/andrea.find/event/187813244",
        },
        {
            name: "Twitter Space",
            description:
                "Host a Twitter Space and create an event for it. Have participants claim the FLOAT to represent their attendance.",
            image: "/twitter.png",
            example: "https://floats.city/0x29d28c3660dbaead/event/252847127",
        },
        {
            name: "Educational Certificate",
            description:
                "Turn off claiming and manually distribute a FLOAT to graduates of your course, bootcamp, or any educational experience.",
            image: "/certificate.png",
            example: "https://floats.city/jacob.find/event/241503135",
        },
        {
            name: "Giveaways",
            description:
                "Have participants claim a FLOAT to enter the giveaway. Then, in Discord using the Emerald bot, use the /randomfloats command to pick a winner.",
            image: "/money-bag.png",
            example: "https://floats.city/jacobmtucker.find/event/228533912",
        },
        {
            name: "Fundraisers",
            description:
                "Created a paid FLOAT and request that people purchase it for a fundraiser, while also claiming a FLOAT marking that they participated in the effort.",
            image: "/hand.png",
            example: "https://floats.city/relief.find/event/191808682",
        },
        {
            name: "Allowlist",
            description:
                "Have users claim a FLOAT to get onto an allowlist. You can download a list of addresses who claimed your FLOAT.",
            image: "/document.png",
            example: "https://floats.city/robenoch.find/event/204594987",
        },
        {
            name: "Merch Voucher",
            description:
                "Want to give out merch to people who get onto a list? Create a FLOAT and have people claim it to be able to purchase merch in the future.",
            image: "/tshirt.png",
            example: "https://floats.city/0x7b3cebdc058c1660/event/192961887",
        },
        {
            name: "Quizzes",
            description:
                "Make a FLOAT Group and then add a bunch of different FLOAT events to that group, each with their own question. For each FLOAT event, make the secret code the answer to that quiz, and then use Emerald bot to validate if a user has all the FLOATs from the Group! ",
            image: "/speech-bubble.png",
            example:
                "https://floats.city/dene.find/group/Icons%20of%20Extreme%20Sports%20-%20QUIZ",
        },
    ];
</script>

<div class="use-cases home-page-padding">
    <h2>Use cases</h2>
    <div class="use-cases-list">
        {#each useCasesList as useCase}
            <div>
                <h3>{useCase.name}</h3>
                <p>{useCase.description}</p>
                <div class="at-bottom">
                    <img src={useCase.image} alt="logo" />
                    <a href={useCase.example}>See Example →</a>
                </div>
            </div>
        {/each}
    </div>
</div>

<style>
    a {
        text-decoration: none;
        font-weight: 700;
        color: rgb(43, 43, 43);
    }
    a:hover {
      text-decoration: underline;
    }

    h3 {
        font-size: 1.45rem;
        font-weight: 600;
        line-height: 1.75rem;
        margin-bottom: 1rem;
        color: rgb(43, 43, 43);
    }
    .use-cases {
        padding-top: 0;
        padding-bottom: 0;
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
        padding: 1.3rem 1.2rem 1rem;
        background-color: rgb(133, 236, 221);
        min-width: 300px;
        display: flex;
        flex-direction: column;
    }

    .use-cases-list > div > p {
        color: rgb(43, 43, 43);
        letter-spacing: -0.01rem;
        line-height: 120%;
        margin-bottom: 1rem;
        flex-grow: 1;
    }

    .at-bottom {
        display: flex;
        position: relative;
        justify-content: space-between;
        align-items: center;
        width: 100%;
    }

    .at-bottom > img {
        max-height: 50px;
        object-fit: contain;
    }
</style>
