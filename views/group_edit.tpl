{include file="views/header.tpl"}
	{if condition="$create"}
		{assign name="title" value="Création d'un group" /}
	{/if}
	{unless condition="$create"}
		{assign name="title" value="Modification d'un group" /}
	{/unless}
{/include}
{include file="views/menu.tpl"}{/include}
	<div class="container">
		<div class="content_with_menu">
			{if condition="$create"}
				<H1>Création d'un group</H1>
			{/if}
			{unless condition="$create"}
				<H1>Modification d'un group</H1>
			{/unless}

			{if condition="$unknown_error"}
				<div class="alert-danger" role="alert">
					Un erreur non géré est survenue.
				</div>
			{/if}
			{if condition="$name_not_valid"}
				<div class="alert-danger" role="alert">
					Nom du groupe non valide.
				</div>
			{/if}
			{if condition="$name_not_unique"}
				<div class="alert-danger" role="alert">
					Nom du groupe non disponible.
				</div>
			{/if}
			<form method="post"  id="edit_form" action="{$script_url/}/groups/{if condition="$create"}create{/if}{unless condition="$create"}edit/{$group.id/}{/unless}">
				<input type="hidden" name="id" value="{$group.id/}">
				<table class="form-table">
					<tr>
						<td>
							Nom:
						</td>
						<td>
							<input type="text" name="name" value="{$group.name/}">
						</td>
					</tr>
				</table>
				{if condition="$create"}
					<input type="submit" class="btn btn-lg btn-default" name="apply" value="Créer">
				{/if}
				{unless condition="$create"}
					<input type="submit" class="btn btn-lg btn-default" name="apply" value="Modifier">
				{/unless}
				<input type="reset" class="btn btn-lg btn-default" name="reset" value="Réinitialiser">
				<input type="submit" class="btn btn-lg btn-default" name="cancel" value="Annuler">
			</form>
		</div>
	</div>
{include file="views/footer.tpl"/}
