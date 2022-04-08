<script>
	import { PAGE_TITLE_EXTENSION } from "$lib/constants";
</script>

<svelte:head>
	<title>About {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="container">
	<h1>A Flow-enabled proof of attendance platform.</h1>

	<video src="/updated_float.mp4" alt="FLOATing island video." autoplay loop>
		<track kind="captions" />
	</video>

	<h2>Configure and create your own FLOAT Events.</h2>
	<p>
		Whether it be a <span class="twitter">Twitter space</span>,
		<span class="discord">Discord call</span>,
		<span class="youtube">YouTube livestream</span>, IRL event, or anything at all, you can
		create a FLOAT Event so participants can remember and have proof that they
		were there.
	</p>

	<h2>Cherish your favorite memories #onFlow.</h2>
	<p>
		Claim FLOATs and show them off as proof that <strong>you</strong> were there.
	</p>

	<h2 id="distribute-directly">Reward users for taking certain actions.</h2>
	<p>
		FLOATs can be configured to only be distributed by the creator. You can do
		this by selecting <span class="emphasis">Not Claimable</span> on the
		<a href="/create">/create</a>
		page. This means the creator can send FLOATs in their own custom transactions
		to reward their community. Want to give people proof that they participated in
		your token drop? Give them a FLOAT automatically in your transaction code when
		the user purchases the NFT.
	</p>

	<h2 id="distribute-directly">Configure your events however you want.</h2>
	<p>
		Want to prevent users from transferring your FLOATs? Want to put a time limit or max capacity
		on your event? Configure your events however you want on the <a href="/create">/create</a> page.
	</p>

	<h2>FLOAT == "Flow Attendance"</h2>
	<p>
		Developed by your <i>best</i> friends at
		<a href="https://ecdao.org" target="_blank"
			><img
				style="height:20px;width:auto;margin-right:4px;"
				src="/emeraldcitylogo.png"
				alt="Emerald City logo"
			/>Emerald City</a
		>, the first DAO on Flow. You may have seen us develop other fun stuff like
		the
		<a
			href="https://emeralddao.notion.site/emeralddao/Emerald-bot-962a1d4c22a5417baad56ba5c79fdfcd"
			target="_blank"
			><img
				style="height:20px;width:auto;margin-right:4px;"
				src="/emeraldboticon.png"
				alt="Emerald bot icon"
			/>Emerald bot
		</a>. If you have, hellooooooooo again!
	</p>
	<p>
		Our goal is to educate the Flow community, build really cool things for the
		Flow ecosystem (like FLOAT), and pave the way for DAOs on Flow. We'd love to
		have you!
	</p>

  <a role="button" class="bold"  href="/create" style="display:block; margin: 0 auto;">Create a FLOAT Event!</a>
</div>

<style>
	video {
		width: 100%;
		margin-bottom: 25px;
	}

	.twitter {
		color: rgb(29 155 239);
	}

	.discord {
		color: rgb(88 101 242);
	}

	.youtube {
		color: rgb(255, 0, 0);
	}
</style>
