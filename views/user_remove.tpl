{include file="header.tpl"}
	{assign name="title" value="Suppression d'un utilisateur" /}
{/include}
{include file="menu.tpl"}{/include}
	<div class="container">
		<div class="content_with_menu">
			<H1>Suppression d'un utilisateur</H1>
			<form method="post"  id="remove_form" action="{$script_url/}/users/remove/{$user.id/}">
				<p>Voulez-vous r�ellement effacer l'utilisateur suivant:
				<input type="hidden" name="id" value="{$user.id/}">
				<table class="form-table">
					<tr>
						<td>
							Identifiant:
						</td>
						<td>
							{$user.user_name/}
						</td>
					</tr>
					<tr>
						<td>
							Pr�nom:
						</td>
						<td>
							{$user.first_name/}
						</td>
					</tr>
					<tr>
						<td>
							Nom de famille:
						</td>
						<td>
							{$user.last_name/}
						</td>
					</tr>
				</table>
				<input type="submit" class="btn btn-lg btn-default" name="apply" value="D�truire">
				<input type="submit" class="btn btn-lg btn-default" name="cancel" value="Annuler">
			</form>
		</div>
	</div>
{include file="footer.tpl"/}
