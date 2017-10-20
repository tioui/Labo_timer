{include file="views/header.tpl"}{assign name="title" value="Liste des membres d'un groupe" /}{/include}
{include file="views/menu.tpl"/}
	<div class="container">
		<div class="content_with_menu">
			<H1>Liste des membres du groupe {$group.name/}</H1>
			<a href="{$script_url/}/groups/member/{$group.id/}/list">Retourner aux membres</a>
			<form method="post"  id="adding_form" action="{$script_url/}/groups/members/{$group.id/}/adding">
			<table class="table">
				<tr>
					<th>
						Nom de connexion
					</th>
					<th>
						Prénom
					</th>
					<th>
						Nom
					</th>
					<th>
					</th>
				</tr>
				{foreach item="member" from="$members"}
				<tr>
					<td>
						{$member.user_name/}
					</td>
					<td>
						{$member.first_name/}
					</td>
					<td>
						{$member.last_name/}
					</td>
					<td>
						<a href="{$script_url/}/groups/member/{$group.id/}/adding/{$member.id/}/">Ajouter</a>
					</td>
				</tr>
				{/foreach}
			</table>
		</div>
	</div>
{include file="views/footer.tpl"/}
