{include file="views/header.tpl"}
	{assign name="title" value="Suppression d'un administrateur" /}
{/include}
{include file="views/menu.tpl"}{/include}
	<div class="container">
		<div class="content_with_menu">
			<H1>Suppression d'un administrateur</H1>
			<form method="post"  id="remove_form" action="{$script_url/}/administrators/remove/{$administrator.id/}">
				<p>Voulez-vous r�ellement effacer l'administrateur suivant:
				<input type="hidden" name="id" value="{$administrator.id/}">
				<table class="form-table">
					<tr>
						<td>
							Identifiant:
						</td>
						<td>
							{$administrator.user_name/}
						</td>
					</tr>
					<tr>
						<td>
							Pr�nom:
						</td>
						<td>
							{$administrator.first_name/}
						</td>
					</tr>
					<tr>
						<td>
							Nom de famille:
						</td>
						<td>
							{$administrator.last_name/}
						</td>
					</tr>
				</table>
				<input type="submit" class="btn btn-lg btn-default" name="apply" value="D�truire">
				<input type="submit" class="btn btn-lg btn-default" name="cancel" value="Annuler">
			</form>
		</div>
	</div>
{include file="views/footer.tpl"/}
