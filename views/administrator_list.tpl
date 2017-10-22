{include file="header.tpl"}{assign name="title" value="Liste des administrateurs" /}{/include}
{include file="menu.tpl"}{assign name="is_list_administrators" value="True"/}{/include}
	<div class="container">
		<div class="content_with_menu">
			<H1>Liste des administrateurs</H1>
			<a href="{$script_url/}/administrators/create/">Créer un nouvel administrateur</a>
			<table class="table">
				<tr>
					<th>
						Identifiant
					</th>
					<th>
						Prénom
					</th>
					<th>
						Nom de famille
					</th>
					<th>
					</th>
				</tr>
				{foreach item="administrator" from="$administrators"}
				<tr>
					<td>
						{$administrator.user_name/}
					</td>
					<td>
						{$administrator.first_name/}
					</td>
					<td>
						{$administrator.last_name/}
					</td>
					<td>
						<a name="edit_link{$administrator.id/}" href="{$script_url/}/administrators/edit/{$administrator.id/}/">Modifier</a> | <a name="delete_link{$administrator.id/}" href="{$script_url/}/administrators/remove/{$administrator.id/}/">Supprimer</a> 
					</td>
				</tr>
				{/foreach}
			</table>
		</div>
	</div>
{include file="footer.tpl"/}
