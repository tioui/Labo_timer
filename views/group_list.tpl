{include file="header.tpl"}{assign name="title" value="Liste des groupes" /}{/include}
{include file="menu.tpl"}{assign name="is_list_groups" value="True"/}{/include}
	<div class="container">
		<div class="content_with_menu">
			<H1>Liste des groupes</H1>
			<a href="{$script_url/}/groups/create/">Créer un nouveau groupe</a>
			<table class="table">
				<tr>
					<th>
						Nom
					</th>
					<th>
					</th>
				</tr>
				{foreach item="group" from="$groups"}
				<tr>
					<td>
						{$group.name/}
					</td>
					<td>
						<a name="member_list{$group.id/}" href="{$script_url/}/groups/member/{$group.id/}/list/">Membres</a> | <a name="edit_link{$group.id/}" href="{$script_url/}/groups/edit/{$group.id/}/">Modifier</a> | <a name="delete_link{$group.id/}" href="{$script_url/}/groups/remove/{$group.id/}/">Supprimer</a>
					</td>
				</tr>
				{/foreach}
			</table>
		</div>
	</div>
{include file="footer.tpl"/}
