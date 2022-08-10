<div class="how-works home-page-padding">
  <h2>DApps that Use FLOAT</h2>
  <div class="works-list">
    <div class="works-list-element share">
      <div>
        <h3>
          <a href="https://bot.ecdao.org/" target="_blank">Emerald bot</a>
        </h3>
        <p>
          Emerald bot is a Discord bot that verifies NFTs/tokens on Flow,
          provides a bunch of useful utilities, and more. Specifically, it can
          verify a user owns a FLOAT in Discord and give them special roles for
          doing so. Check out <a
            href="https://www.notion.so/emeralddao/FLOAT-Commands-8517b547c87e43a6a5fd4fdc93edbb9f"
            target="_blank">the docs</a> for some useful tips and tricks.
        </p>
      </div>
      <img src="/emerald-bot.png" alt="emerald bot" />
    </div>
    <div class="works-list-element share">
      <div>
        <h3><a href="https://drizzle33.app/" target="_blank">Drizzle</a></h3>
        <p>
          Drizzle is a platform that allows you to easily airdrop tokens and
          raffle away NFTs. You can set up drops/raffles on Drizzle that require
          users to own FLOATs before participating! Set up a FLOAT event, have
          users claim it, and then only allow those users to participate in the
          fun :) Drizzle is a platform that allows you to easily airdrop tokens
          and raffle away NFTs.
        </p>
      </div>
      <img src="/drizzle.png" alt="drizzle" />
    </div>
    <div class="works-list-element share">
      <div>
        <h3><a href="https://geeft.ecdao.org/" target="_blank">Geeft</a></h3>
        <p>
          Geeft is a gifting platform on Flow. You can distribute NFTs and
          tokens to your friends and family as a present and they can open it up
          at any time! You can also Geeft FLOATs {"<3"}.
        </p>
      </div>
      <img src="/geeft.jpeg" alt="geeft" />
    </div>
    <div class="works-list-element share">
      <div>
        <h3><a href="https://touchstone.city/">Touchstone (coming soon)</a></h3>
        <p>
          Touchstone allows you to create your own NFT Collection without
          knowing any code whatsoever. It automatically creates and deploy your
          contract to your account and sets up a primary sales page for you. You
          can also require users to own a FLOAT to mint from your collection!
        </p>
      </div>
      <img src="/touchstone.png" alt="touchstone" />
    </div>
  </div>
</div>

<style>
  a {
    text-decoration: none;
    font-weight: 700;
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
    background-color: #27414d;
  }
  .works-list > div:nth-child(1) p,
  .works-list > div:nth-child(1) a {
    color: white;
  }
  .works-list > div:nth-child(2) {
    background-color: #e5fced;
  }
  .works-list > div:nth-child(2) p,
  .works-list > div:nth-child(2) a {
    color: rgb(43, 43, 43);
  }
  .works-list > div:nth-child(3) {
    background-color: #b5e1d0;
  }
  .works-list > div:nth-child(3) p,
  .works-list > div:nth-child(3) a {
    color: rgb(43, 43, 43);
  }
  .works-list > div:nth-child(4) {
    background-color: #14063e;
  }
  .works-list > div:nth-child(4) p,
  .works-list > div:nth-child(4) a {
    color: white;
  }

  .works-list-element {
    border-radius: 0.6rem;
    box-sizing: border-box;
    gap: 2.8rem;
    padding: 2.4rem 1.6rem 1.6rem;
    width: 100%;
  }

  .works-list-element img {
    position: relative;
    display: inline-block;
    vertical-align: top;
    overflow: hidden;
    border-radius: 0.75rem;
    object-fit: contain;
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
  }

  h2 {
    font-size: 4.3rem;
    font-weight: 600;
    line-height: 120%;
    margin-bottom: 2.4rem;
  }

  @media all and (max-width: 768px) {
    .share {
      width: 100%;
    }

    .share img {
      max-width: 100%;
    }
  }
</style>
