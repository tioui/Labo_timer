{include file="views/header.tpl"}{assign name="title" value="Liste des invité de laboratoire" /}{/include}
{include file="views/menu.tpl"/}
	<div class="container">
		<div class="content_with_menu">
			<H1>Ajouter un groupe au laboratoire {$laboratory.name/} du {$laboratory.date/} de {$laboratory.start_time/} à {$laboratory.end_time/}</H1>
			<a href="{$script_url/}/laboratories/guest/{$laboratory.id/}/list">Retourner aux invités</a>
			<form method="post"  id="adding_form" action="{$script_url/}/laboratories/guests/{$laboratory.id/}/adding">
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
						<a href="{$script_url/}/laboratories/guest/{$laboratory.id/}/adding_group/{$group.id/}/">Ajouter</a>
					</td>
				</tr>
				{/foreach}
			</table>
		</div>
	</div>
{include file="views/footer.tpl"/}
