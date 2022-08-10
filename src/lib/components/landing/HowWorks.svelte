<div class="how-works home-page-padding">
    <h2>How It Works</h2>
    <div class="works-list">
        <div class="works-list-element wide">
            <div>
                <h3>Overview</h3>
                <ul>
                    <li>
                        <b>What is a FLOAT?</b> The name "FLOAT" comes from "Flow
                        Attendance". FLOATs are NFTs that represent users' attendance
                        in whatever aspect you choose, whether it be attending a
                        Twitter Space, receiving a certificate for graduating a bootcamp,
                        or participating in a fundraiser.
                    </li>
                    <li>
                        <b>What is their use?</b> The utility of a FLOAT is entirely
                        up to its creator. Someone (let's say a community manager)
                        can create a FLOAT for an event, have their community claim
                        it, and then give access rights, perks, and whatever else
                        to people who own that unique FLOAT. One way a community
                        manager would do this is by using Emerald bot (see section
                        below).
                    </li>
                    <li>
                        <b>Who can make a FLOAT?</b> Anyone, for free.
                    </li>
                    <li>
                        <b>Can I see some examples?</b> Check the "Use Cases" section
                        above.
                    </li>
                </ul>
            </div>
            <img src="/social-card.png" alt="social card" />
        </div>
        <div class="works-list-element share">
            <div>
                <h3>Admin Capabilities</h3>
                <ul>
                    <li>
                        Distribute FLOATs manually to users, bypassing claim
                        requirements.
                    </li>
                    <li>
                        Batch upload {"<="} 100 wallet addresses in a CSV file to
                        give tons of FLOATs away.
                    </li>
                    <li>
                        Turn on/off claiming and transferring of FLOATs for each
                        of your events at any point in time.
                    </li>
                </ul>
            </div>
            <img src="/admin-cap.png" alt="admin capabilities" />
        </div>
        <div class="works-list-element share">
            <div>
                <h3>Emerald Bot Integration</h3>
                <ul>
                    <li>
                        Verify a user owns a FLOAT in Discord using the <a
                            href="https://bot.ecdao.org/"
                            target="_blank">Emerald bot</a
                        >.
                    </li>
                    <li>Display your FLOAT in Discord.</li>
                    <li>
                        Grant roles to community members for holding specific or
                        groups of FLOATs.
                    </li>
                </ul>
            </div>
            <img src="/emerald-bot-min.png" alt="emerald bot" />
        </div>
        <div class="works-list-element wide">
            <div>
                <h3>Live Feeds</h3>
                <ul>
                    <li>
                        To see a live claiming feed, as well as information
                        about the total number of FLOAT mints and events
                        created, check out our <a href="/live">live</a> page.
                    </li>
                    <li>
                        You can also burn your FLOATs in the <a
                            href="/incinerator"
                            style="color: #df523d;">Incinerator</a> and watch as
                        tons of other FLOATs are thrown in the fire too!
                    </li>
                </ul>
            </div>
            <img src="/live-page-min.jpg" alt="live page" />
        </div>
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

    .how-works {
        padding-top: 0;
        padding-bottom: 0;
    }

    .works-list {
        display: flex;
        flex-wrap: wrap;
        gap: 0.9rem;
    }

    .works-list > div:nth-child(1) {
        background-color: rgb(133, 202, 236);
    }
    .works-list > div:nth-child(2) {
        background-color: rgb(133, 236, 221);
    }
    .works-list > div:nth-child(3) {
        background-color: rgb(133, 236, 196);
    }
    .works-list > div:nth-child(4) {
        background-color: rgb(133, 236, 155);
    }

    .works-list-element {
        border-radius: 0.6rem;
        box-sizing: border-box;
        gap: 2.8rem;
        padding: 2.4rem 1.6rem 1.6rem;
        width: 100%;
    }

    .works-list-element ul {
        letter-spacing: -0.01rem;
        line-height: 140%;
        padding-inline-start: 1.4rem;
    }

    li {
        color: rgb(43, 43, 43);
    }

    .works-list-element img {
        position: relative;
        display: inline-block;
        vertical-align: top;
        overflow: hidden;
        border-radius: 0.75rem;
        object-fit: contain;
    }

    .wide img {
        max-width: 50%;
    }

    .wide {
        display: flex;
        align-content: space-around;
    }

    .share {
        width: calc(50% - 0.45rem);
    }

    .works-list-element.share {
        display: flex;
        flex-direction: column;
    }

    .share > div {
        flex-grow: 1;
    }

    h3 {
        font-size: 1.45rem;
        font-weight: 600;
        line-height: 1.75rem;
        margin-bottom: 1rem;
        color: black;
    }

    h2 {
        font-size: 4.3rem;
        font-weight: 600;
        line-height: 120%;
        margin-bottom: 2.4rem;
    }

    @media all and (max-width: 768px) {
        .wide {
            display: block;
        }

        .share {
            width: 100%;
        }

        .wide img,
        .share img {
            max-width: 100%;
        }
    }
</style>
