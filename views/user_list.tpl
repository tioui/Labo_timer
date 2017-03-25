{include file="views/header.tpl"}{assign name="title" value="Liste des utilisateurs" /}{/include}
{include file="views/menu.tpl"}{assign name="is_list_users" value="True"/}{/include}
	<div class="container">
		<div class="content_with_menu">
			<H1>Liste des utilisateurs</H1>
			<a href="{$script_url/}/users/create/">Créer un nouvel utilisateur</a>
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
				{foreach item="user" from="$users"}
				<tr>
					<td>
						{$user.user_name/}
					</td>
					<td>
						{$user.first_name/}
					</td>
					<td>
						{$user.last_name/}
					</td>
					<td>
						<a name="edit_link{$user.id/}" href="{$script_url/}/users/edit/{$user.id/}/">Modifier</a> | <a name="delete_link{$user.id/}" href="{$script_url/}/users/remove/{$user.id/}/">Supprimer</a> 
					</td>
				</tr>
				{/foreach}
			</table>
		</div>
	</div>
{include file="views/footer.tpl"/}
