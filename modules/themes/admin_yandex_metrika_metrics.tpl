<div class="admin_yandex_metrika_metrics">
	<style>
		.admin_yandex_metrika_metrics .table .table > div:hover {background-color:#eee;}
		.admin_yandex_metrika_metrics .table .table > div > span {text-align:center;}
		.admin_yandex_metrika_metrics .table .table > div > span.active {background-color:#eee;}
		.admin_yandex_metrika_metrics .table .table > div.active {background-color:#aaa;}
		.admin_yandex_metrika_metrics .table .table > div.active > span.active {background-color:#888;}
		.admin_yandex_metrika_metrics .table .table > div:hover > span.active:hover {background-color:#bbb;}
		.admin_yandex_metrika_metrics .table .changes {color:green; font-weight:bold;}
		.admin_yandex_metrika_metrics .table .th span span {color:#ccc;}
	</style>
	<script sync>
		(function($, script){
			$(script).parent().one("DOMNodeInserted", function(e){ // Загрузка родительского элемента
				
			}).on("click", "a.update", function(e){
				var yandex_metrika_id = $(e.currentTarget).parents("[yandex_metrika_id]").attr("yandex_metrika_id");
				var yandex_metrika_period_id = $(e.currentTarget).parents("[yandex_metrika_period_id]").attr("yandex_metrika_period_id");
				$(e.currentTarget).parents("[yandex_metrika_id]").addClass("active");

				var top = $(e.currentTarget).offset().top;
				var scroll = $(document).scrollTop();
				var height = $(window).height();

				if((res = Math.abs(top-scroll-height/2)) < 100){
					$(document).scrollTop(top-height/2);
				}else{ console.log("res:", res); }
				
					$.post("/<?=$arg['modpath']?>:<?=$arg['fn']?>/null", {yandex_metrika_id:yandex_metrika_id, yandex_metrika_period_id:yandex_metrika_period_id}, function(data){
						console.log("data:",data)
						var users = $(e.currentTarget).parents("[yandex_metrika_id]").find(".active .users span.count").text()|0;
						$(e.currentTarget).parents("[yandex_metrika_id]").find(".active .users span.count").text(users);
						var changes = (users == data['totals'][0]) ? "" : "+"+(parseInt(data['totals'][0]) - parseInt(users));
						$(e.currentTarget).parents("[yandex_metrika_id]").find(".active .users span.changes").text(changes);

						var visits = $(e.currentTarget).parents("[yandex_metrika_id]").find(".active .visits span.count").text()|0;
						$(e.currentTarget).parents("[yandex_metrika_id]").find(".active .visits span.count").text(visits);
						var changes = (visits == data['totals'][1]) ? "" : "+"+(parseInt(data['totals'][1]) - parseInt(visits));
						$(e.currentTarget).parents("[yandex_metrika_id]").find(".active .visits span.changes").text(changes);

						var pageviews = $(e.currentTarget).parents("[yandex_metrika_id]").find(".active .pageviews span.count").text()|0;
						$(e.currentTarget).parents("[yandex_metrika_id]").find(".active .pageviews span.count").text(pageviews);
						var changes = (pageviews == data['totals'][2]) ? "" : "+"+(parseInt(data['totals'][2]) - parseInt(pageviews));
						$(e.currentTarget).parents("[yandex_metrika_id]").find(".active .pageviews span.changes").text(changes);

						$(e.currentTarget).parents("[yandex_metrika_id]").removeClass("active");
					}, "json").fail(function(error){
						alert(error.responseText);
					})
			}).on("click", "a.upgrade", function(){
				(function(a){
					$(a).trigger("click");
					var func = arguments;
					if(next = $(a).parents("[yandex_metrika_id]").next().find("a.update")){
						setTimeout(function(){
							func.callee(next);
						}, 1000)
					}
				})($(".admin_yandex_metrika_metrics .table a.update:first"))
			})/*.on("click", ".table > div.th > span", function(e){
				var index = $(e.currentTarget).index();
				if(index > 0){
					$(e.delegateTarget).find(".table > div > span:nth-child("+(index+1)+")").hide();
				}
			})*/
		})(jQuery, document.scripts[document.scripts.length-1])
	</script>
	<div yandex_metrika_period_id="<?=$tpl['yandex_metrika_period']['id']?>">
		<span style="float:right; line-height:25px;">
			<? for($i=0; $i>-10; $i--): ?>
				<a href="/<?=$arg['modpath']?>:<?=$arg['fn']?><?=($i ? "/week:{$i}" : "")?>" style="font-weight:<?=($i == get($_GET, "week") ? "bold" : "normal")?>;"><?=$i?></a>
			<? endfor; ?>
			<?=$tpl['yandex_metrika_period']['date1']?> - <?=$tpl['yandex_metrika_period']['date2']?>
			<a onClick="javascript:return false;" class="upgrade">Обновить все</a>
		</span>
		<? if(!$THEMES_YANDEX_METRIKA = rb("themes-yandex_metrika")): mpre("Ошибка выборки метрих хостов") ?>
		<? elseif(!$THEMES_YANDEX_METRIKA = array_filter(array_map(function($themes_yandex_metrika){
				if($themes_yandex_metrika['index_id'] <= 0){// mpre("Отрицательный хост");
				}else{ return $themes_yandex_metrika; }
			}, $THEMES_YANDEX_METRIKA))): mpre("Ошибка удаления отрицательных значений") ?>
		<? elseif(!$THEMES_INDEX = rb("themes-index")): mpre("ОШибка выборки хостов") ?>
		<? else:// mpre($THEMES_YANDEX_METRIKA) ?>
			<h1 style="margin-right:100px;">Метрики</h1>
			<? if($tpl['yandex_metrika_period:all'] = rb("themes-yandex_metrika_period", 6)): ?>
				<div class="table">
					<div>
						<span style="width:50%;">
							<div class="table">
								<div class="th">
									<span>Счетчик</span>
									<span>Сайт</span>
									<? foreach($tpl['yandex_metrika_period:all'] as $yandex_metrika_period): ?>
										<span><?=$yandex_metrika_period['date1']?>/<?=$yandex_metrika_period['date2']?></span>
									<? endforeach; ?>
								</div>
								<? foreach($THEMES_INDEX as $themes_index): ?>
									<? if($themes_index['index_id']):// mpre("Сайт является зеркалом", $themes_index) ?>
									<? elseif(preg_match("#\d+\.\d+\.\d+\.\d+#", $themes_index['name'])):// mpre("Хост с адресом в имени", $themes_index) ?>
									<? elseif("deny" == $themes_index['theme']):// mpre("На сайте устанволена тема заглушка", $themes_index) ?>
									<? elseif(!$yandex_metrika = rb("themes-yandex_metrika", "index_id", $themes_index['id'])):// mpre("Ошибка поиска метрики сайта") ?>
									<? elseif(!$YANDEX_METRIKA[$yandex_metrika['id']] = $yandex_metrika): mpre("Ошибка формирования списка сайтов") ?>
									<? else: ?>
										<? ($yandex_metrika_metrics = rb("themes-yandex_metrika_metrics", "yandex_metrika_period_id", "yandex_metrika_id", "yandex_metrika_dimensions_id", $tpl['yandex_metrika_period']['id'], $yandex_metrika['id'], 0)) ?>
										<div yandex_metrika_id="<?=$yandex_metrika['id']?>">
											<span>
												<a class="update" onClick="javascript:return false;" href="/themes:admin/r:mp_themes_yandex_metrika?&where[id]=<?=$yandex_metrika['id']?>"><?=$yandex_metrika['id']?></a>
											</span>
											<span>
												<? if($themes_index = rb("themes-index", "id", $yandex_metrika['index_id'])): ?>
													<?=$themes_index['name']?>
												<? endif; ?>
											</span>
											<? foreach($tpl['yandex_metrika_period:all'] as $yandex_metrika_period): ?>
												<span class="<?=($tpl['yandex_metrika_period']['id'] == $yandex_metrika_period['id'] ? "active" : "")?>">
													<? if($yandex_metrika_metrics = rb("themes-yandex_metrika_metrics", "yandex_metrika_period_id", "yandex_metrika_id", "yandex_metrika_dimensions_id", $yandex_metrika_period['id'], $yandex_metrika['id'], 0)): ?>
														<?// mpre("Значения метрики", $yandex_metrika_metrics) ?>
													<? endif; ?>
													<span class="users" title="Посетители">
														<span class="count"><?=get($yandex_metrika_metrics, 'users')?></span>
														<span class="changes"></span>
													</span> /
													<span class="visits" title="Визиты">
														<span class="count"><?=get($yandex_metrika_metrics, 'visits')?></span>
														<span class="changes"></span>
													</span> /
													<span class="pageviews" title="Просмотры">
														<span class="count"><?=get($yandex_metrika_metrics, 'pageviews')?></span>
														<span class="changes"></span>
													</span>
												</span>
											<? endforeach; ?>
										</div>
									<? endif; ?>
								<? endforeach; ?>
								<div class="th">
									<span></span>
									<span>Посещения всего:</span>
									<? foreach($tpl['yandex_metrika_period:all'] as $yandex_metrika_period): ?>
										<span>
											<? if($tpl['yandex_metrika_metrics'] = rb("themes-yandex_metrika_metrics", "yandex_metrika_period_id", 'yandex_metrika_id', "yandex_metrika_dimensions_id", "id", $yandex_metrika_period['id'], $THEMES_YANDEX_METRIKA, 0)): ?>
												<span title="Посетители"><?=array_sum(array_column($tpl['yandex_metrika_metrics'], "users"))?></span> /
												<span title="Визиты"><?=array_sum(array_column($tpl['yandex_metrika_metrics'], "visits"))?></span> /
												<span title="Просмотры"><?=array_sum(array_column($tpl['yandex_metrika_metrics'], "pageviews"))?></span>
											<? endif; ?>
										</span>
									<? endforeach; ?>
								</div>

								<? if(!$THEMES_YANDEX_METRIKA_DIMENSIONS = rb("themes-yandex_metrika_dimensions")): mpre("Ошибка выборки списка источников") ?>
								<? elseif(!$_THEMES_YANDEX_METRIKA_DIMENSIONS = rb($THEMES_YANDEX_METRIKA_DIMENSIONS, "yandex_metrika_dimensions_id", "id", '[0,NULL]')): mpre("Ошибка выборки списка измерений") ?>
								<? else:// mpre($YANDEX_METRIKA) ?>
									<? foreach($_THEMES_YANDEX_METRIKA_DIMENSIONS as $themes_yandex_metrika_dimensions): ?>
										<div>
											<span><a href="/themes:admin/r:mp_themes_yandex_metrika_dimensions?&where[id]=<?=$themes_yandex_metrika_dimensions['id']?>"><?=$themes_yandex_metrika_dimensions['id']?></a></span>
											<span><?=$themes_yandex_metrika_dimensions['name']?>:</span>
											<? foreach($tpl['yandex_metrika_period:all'] as $yandex_metrika_period): ?>
												<span>
													<? if(!is_array($THEMES_YANDEX_METRIKA_DIMENSIONS_['Нижестоящие'] = rb($THEMES_YANDEX_METRIKA_DIMENSIONS, "yandex_metrika_dimensions_id", "id", $themes_yandex_metrika_dimensions['id']))): mpre("Ошибка выборки нижестоящих элементов") ?>
													<? elseif(!$THEMES_YANDEX_METRIKA_DIMENSIONS_['Нижестоящие'][$themes_yandex_metrika_dimensions['id']] = $themes_yandex_metrika_dimensions): mpre("Ошибка добавления текущей") ?>
													<? elseif(!$YANDEX_METRIKA_METRICS = rb("themes-yandex_metrika_metrics", "yandex_metrika_period_id", 'yandex_metrika_id', "yandex_metrika_dimensions_id", "id", $yandex_metrika_period['id'], $THEMES_YANDEX_METRIKA, $THEMES_YANDEX_METRIKA_DIMENSIONS_['Нижестоящие'])):// mpre("Ошибка выборки данных метрики") ?>
													<? else:// mpre($YANDEX_METRIKA_METRICS) ?>
														<a href="/themes:admin/r:mp_themes_yandex_metrika_metrics?&where[yandex_metrika_dimensions_id]=<?=$themes_yandex_metrika_dimensions['id']?>&where[yandex_metrika_period_id]=<?=$yandex_metrika_period['id']?>">
															<span title="Посетители"><?=array_sum(array_column($YANDEX_METRIKA_METRICS, "users"))?></span> /
															<span title="Визиты"><?=array_sum(array_column($YANDEX_METRIKA_METRICS, "visits"))?></span> /
															<span title="Просмотры"><?=array_sum(array_column($YANDEX_METRIKA_METRICS, "pageviews"))?></span>
														</a>
													<? endif; ?>
												</span>
											<? endforeach; ?>
										</div>
									<? endforeach; ?>
								<? endif; ?>
							</div>
						</span>
					</div>
				</div>
			<? endif; ?>
		<? endif; ?>
	</div>
</div>
