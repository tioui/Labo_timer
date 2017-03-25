{include file="views/header.tpl"}{assign name="title" value="Liste des laboratoires" /}{/include}
{include file="views/menu.tpl"}{assign name="is_list_laboratories" value="True"/}{/include}
	<div class="container">
		<div class="content_with_menu">
			<H1>Liste des laboratoires</H1>
			<a href="{$script_url/}/laboratories/create/">Cr�er un nouveau laboratoire</a>
			<table class="table">
				<tr>
					<th>
						Nom
					</th>
					<th>
						Mot de passe	
					</th>
					<th>
						Date
					</th>
					<th>
						Heure de d�but
					</th>
					<th>
						Heure de fin
					</th>
					<th>
					</th>
				</tr>
				{foreach item="laboratory" from="$laboratories"}
				<tr>
					<td>
						{$laboratory.name/}
					</td>
					<td>
						{$laboratory.password/}
					</td>
					<td>
						{$laboratory.date/}
					</td>
					<td>
						{$laboratory.start_time/}
					</td>
					<td>
						{$laboratory.end_time/}
					</td>
					<td>
						<a name="guest_list{$laboratory.id/}" href="{$script_url/}/laboratories/guest/{$laboratory.id/}/list/">Participants</a> | <a name="edit_link{$laboratory.id/}" href="{$script_url/}/laboratories/edit/{$laboratory.id/}/">Modifier</a> | <a name="delete_link{$laboratory.id/}" href="{$script_url/}/laboratories/remove/{$laboratory.id/}/">Supprimer</a> 
					</td>
				</tr>
				{/foreach}
			</table>
		</div>
	</div>
{include file="views/footer.tpl"/}
