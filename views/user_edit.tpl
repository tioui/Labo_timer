{include file="header.tpl"}
	{if condition="$create"}
		{assign name="title" value="Création d'un utilisateur" /}
	{/if}
	{unless condition="$create"}
		{assign name="title" value="Modification d'un utilisateur" /}
	{/unless}
{/include}
{include file="menu.tpl"}{/include}
	<div class="container">
		<div class="content_with_menu">
			{if condition="$create"}
				<H1>Création d'un utilisateur</H1>
			{/if}
			{unless condition="$create"}
				<H1>Modification d'un utilisateur</H1>
			{/unless}

			{if condition="$unknown_error"}
				<div class="alert-danger" role="alert">
					Un erreur non géré est survenue.
				</div>
			{/if}
			{if condition="$user_name_not_valid"}
				<div class="alert-danger" role="alert">
					Identifiant de l'administrateur non valide.
				</div>
			{/if}
			{if condition="$user_name_not_unique"}
				<div class="alert-danger" role="alert">
					Identifiant de l'administrateur non disponible.
				</div>
			{/if}
			{if condition="$first_name_not_valid"}
				<div class="alert-danger" role="alert">
					Prénom de l'administrateur n'est pas valide.
				</div>
			{/if}
			{if condition="$last_name_not_valid"}
				<div class="alert-danger" role="alert">
					Nom de famille de l'administrateur n'est pas valide.
				</div>
			{/if}
			<form method="post"  id="edit_form" action="{$script_url/}/users/{if condition="$create"}create{/if}{unless condition="$create"}edit/{$user.id/}{/unless}">
				<input type="hidden" name="id" value="{$user.id/}">
				<table class="form-table">
					<tr>
						<td>
							Identifiant:
						</td>
						<td>
							<input type="text" name="user_name" value="{$user.user_name/}">
						</td>
					</tr>
					<tr>
						<td>
							Prénom:
						</td>
						<td>
							<input type="text" name="first_name" value="{$user.first_name/}">
						</td>
					</tr>
					<tr>
						<td>
							Nom de Famille:
						</td>
						<td>
							<input type="text" name="last_name" value="{$user.last_name/}">
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
{include file="footer.tpl"/}
