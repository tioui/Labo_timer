{include file="views/header.tpl"}{assign name="title" value="Administration d'un laboratoire." /}{/include}
{include file="views/menu.tpl"/}
	<div class="container">
		<div class="content_with_menu">
			<H1>Laboratoire {$laboratory.name/}</H1>
			<table class="table">
				<tr>
					<th>
						Nom
					</th>
					<th>
						Temps en attente
					</th>
					<th>
					</th>
				</tr>
				{foreach item="intervention" from="$interventions"}
				<tr>
					<td>
						{$intervention.name/}
					</td>
					<td>
						{$intervention.time/}
					</td>
					<td>
						<a name="answering{$intervention.id/}" href="{$script_url/}/labo/{$laboratory.id/}/admin/answering/{$intervention.id/}">Répondre</a> 
					</td>
				</tr>
				{/foreach}
			</table>
		</div>
	</div>
{include file="views/footer.tpl"/}
