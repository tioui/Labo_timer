{include file="views/header.tpl"}{assign name="title" value="Liste des invit� de laboratoire" /}{/include}
{include file="views/menu.tpl"/}
	<div class="container">
		<div class="content_with_menu">
			<H1>Liste des invit� du laboratoire {$laboratory.name/} du {$laboratory.date/} de {$laboratory.start_time/} � {$laboratory.end_time/}</H1>
			<a href="{$script_url/}/laboratories/guest/{$laboratory.id/}/list">Retourner aux invit�s</a>
			<form method="post"  id="adding_form" action="{$script_url/}/laboratories/guests/{$laboratory.id/}/adding">
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
						<a href="{$script_url/}/laboratories/guest/{$laboratory.id/}/adding/{$guest.id/}/">Ajouter</a>
					</td>
				</tr>
				{/foreach}
			</table>
		</div>
	</div>
{include file="views/footer.tpl"/}
