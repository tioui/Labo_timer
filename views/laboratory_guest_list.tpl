{include file="header.tpl"}{assign name="title" value="Liste des invit� de laboratoire" /}{/include}
{include file="menu.tpl"/}
	<div class="container">
		<div class="content_with_menu">
			<H1>Liste des invit� du laboratoire {$laboratory.name/} du {$laboratory.date/} de {$laboratory.start_time/} � {$laboratory.end_time/}</H1>
			<a href="{$script_url/}/laboratories/guest/{$laboratory.id/}/adding">Ajouter des invit�s</a>&nbsp |&nbsp
			<a href="{$script_url/}/laboratories/guest/{$laboratory.id/}/adding_group">Ajouter un groupe</a>
			<table class="table">
				<tr>
					<th>
						Nom de connexion
					</th>
					<th>
						Pr�nom
					</th>
					<th>
						Nom
					</th>
					<th>
					</th>
				</tr>
				{foreach item="guest" from="$guests"}
				<tr>
					<td>
						{$guest.user_name/}
					</td>
					<td>
						{$guest.first_name/}
					</td>
					<td>
						{$guest.last_name/}
					</td>
					<td>
						<a name="delete_link{$guest.id/}" href="{$script_url/}/laboratories/guest/{$laboratory.id/}/remove/{$guest.id/}/">Enlever</a> 
					</td>
				</tr>
				{/foreach}
			</table>
		</div>
	</div>
{include file="footer.tpl"/}
