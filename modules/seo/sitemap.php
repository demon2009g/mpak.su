<?

if(array_key_exists("null", $_GET)){
	header("Content-Type: text/xml");
}

?><?="<"?>?xml version="1.0" encoding="UTF-8" ?<?=">"?> 
<urlset
			xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
					http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
	<? if($themes_index = get($conf, 'themes', 'index')): ?> 
		<? if(!$SEO_INDEX_THEMES = rb('seo-index_themes', 10000, "themes_index", "id", $themes_index['id'])): mpre("Ошибка выборки адресов сайта") ?>
		<? elseif(!$SEO_INDEX = rb('seo-index', 'id', 'id', rb($SEO_INDEX_THEMES, 'index_id'))): mpre("Ошибка выборки внешних адресов") ?>
		<? else: ?>
			<? foreach($SEO_INDEX as $seo_index):// mpre($seo_index_themes) ?>
				<? if(!$seo_index_themes = rb($SEO_INDEX_THEMES, 'index_id', $seo_index['id'])): mpre("Ошибка выборки внутренней ссылки") ?>
				<? elseif(!$seo_index = rb("seo-index", "id", $seo_index_themes['index_id'])):// mpre("Адрес не найден") ?> 
				<? elseif(array_key_exists("hide", $seo_index) && get($seo_index, 'hide')):// mpre("Поле скрыто") ?>
				<? elseif(get($seo_index, 'index_changefreq_id') && !($seo_index_changefreq = rb("seo-index_changefreq", "id", $seo_index['index_changefreq_id']))/* & ($seo_index_changefreq = []*/): mpre("Период изменения не найден") ?>
				<? elseif(!($up = (get($seo_index_changefreq, 'period') ? time() - time()%$seo_index_changefreq['period']+$themes_index['up']%$seo_index_changefreq['period'] : $themes_index['up'])) &0): mpre("Ошибка расчета времени обновления") ?>
				<? else:// mpre($seo_index) ?>
						<url>
							<loc>http://<?=$themes_index['name']?><?=$seo_index['name']?></loc>
							<lastmod><?=(get($themes_index, 'up') ? date('c', $up) : "")?></lastmod>
							<changefreq><?=get($seo_index_changefreq, 'alias')?></changefreq>
							<priority><?=$seo_index['priority']?></priority>
						</url>
				<? endif; ?> 
			<? endforeach; ?> 
		<? endif; ?>
	<? else: ?>
		<? foreach(rb("seo-index") as $seo_index): ?>
			<? if(array_key_exists("hide", $seo_index) && get($seo_index, 'hide')):// mpre("Поле скрыто") ?>
			<? else: ?>
				<url>
					<loc>http://<?=$_SERVER['HTTP_HOST']?><?=$seo_index['name']?></loc>
					<priority><?=$seo_index['priority']?></priority>
				</url>
			<? endif; ?>
		<? endforeach; ?> 
	<? endif; ?> 
</urlset>
