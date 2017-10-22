{include file="header.tpl"}
	{assign name="title" value="Suppression d'un groupe" /}
{/include}
{include file="menu.tpl"}{/include}
	<div class="container">
		<div class="content_with_menu">
			<H1>Suppression d'un groupe</H1>
			<form method="post"  id="remove_form" action="{$script_url/}/groups/remove/{$group.id/}">
				<p>Voulez-vous réellement effacer le groupe: {$group.name/}</p>
				<input type="hidden" name="id" value="{$group.id/}">
				<input type="submit" class="btn btn-lg btn-default" name="apply" value="Détruire">
				<input type="submit" class="btn btn-lg btn-default" name="cancel" value="Annuler">
			</form>
		</div>
	</div>
{include file="footer.tpl"/}
