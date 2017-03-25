{include file="views/header.tpl"}
	{if condition="$create"}
		{assign name="title" value="Création d'un administrateur" /}
	{/if}
	{unless condition="$create"}
		{assign name="title" value="Modification d'un administrateur" /}
	{/unless}
{/include}
{include file="views/menu.tpl"}{/include}
	<div class="container">
		<div class="content_with_menu">
			{if condition="$create"}
				<H1>Création d'un administrateur</H1>
			{/if}
			{unless condition="$create"}
				<H1>Modification d'un administrateur</H1>
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
			{if condition="$password_not_valid"}
				<div class="alert-danger" role="alert">
					Mot de passe de l'administrateur n'est pas valide.
				</div>
			{/if}
			{if condition="$password_differ"}
				<div class="alert-danger" role="alert">
					Les deux mots de passe inscrient ne concordent pas.
				</div>
			{/if}
			{if condition="$password_empty"}
				<div class="alert-danger" role="alert">
					Le mot de passe ne peut pas être vide.
				</div>
			{/if}
			<form method="post"  id="edit_form" action="{$script_url/}/administrators/{if condition="$create"}create{/if}{unless condition="$create"}edit/{$administrator.id/}{/unless}">
				<input type="hidden" name="id" value="{$administrator.id/}">
				<table class="form-table">
					<tr>
						<td>
							Identifiant:
						</td>
						<td>
							<input type="text" name="user_name" value="{$administrator.user_name/}">
						</td>
					</tr>
					<tr>
						<td>
							Prénom:
						</td>
						<td>
							<input type="text" name="first_name" value="{$administrator.first_name/}">
						</td>
					</tr>
					<tr>
						<td>
							Nom de Famille:
						</td>
						<td>
							<input type="text" name="last_name" value="{$administrator.last_name/}">
						</td>
					</tr>
					<tr>
						<td>
							Mot de passe:
						</td>
						<td>
							<input type="password" name="password1" value="">
						</td>
					</tr>
					<tr>
						<td>
							Confirmation du mot de passe:
						</td>
						<td>
							<input type="password" name="password2" value="">
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
