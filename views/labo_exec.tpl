{include file="views/header.tpl"}{assign name="title" value="Laboratoire" /}{/include}
		<div class="container">
			<center>
				<H1>Laboratoire {$laboratory.name/}</H1>

				<p>Nombre de questions en attente: {$nb_questions/}</p>
				<div name="hand" {if condition="$is_raised"}style="display: none;"{/if}><a href="{$script_url/}/labo/{$laboratory.id/}/raise"><img src="{$script_url/}/www/images/hand.png" title="Poser une question" alt="Poser une question"/></a></div>
				<div name="raised" {unless condition="$is_raised"}style="display: none;"{/unless}><a href="{$script_url/}/labo/{$laboratory.id/}/lower"><img src="{$script_url/}/www/images/raised.png" title="En attente de réponse" alt="En attente de réponse"/></a></div>
			</center>
		<div>
<script type="text/javascript" src="{$script_url/}/www/scripts/hand_raise.js"></script>
<script>
setInterval(checkRaised, 5000, "{$script_url/}/labo/{$laboratory.id/}/is_raised")
</script>

{include file="views/footer.tpl"/}
