import 'package:embed_annotation/embed_annotation.dart';
import 'package:shelf_plus/shelf_plus.dart';

part 'pages.g.dart';

@EmbedStr('/public/about.html')
const aboutHtml = _$aboutHtml;

@EmbedStr('/public/bulma.min.css')
const bulmaMinCss = _$bulmaMinCss;

@EmbedStr('/public/chart.js')
const chartJs = _$chartJs;

@EmbedStr('/public/config.html')
const configHtml = _$configHtml;

@EmbedStr('/public/config.js')
const configJs = _$configJs;

@EmbedStr('/public/index.html')
const indexHtml = _$indexHtml;

@EmbedStr('/public/index.js')
const indexJs = _$indexJs;

@EmbedBinary('/public/logo.png')
const logoPng = _$logoPng;

@EmbedStr('/public/mining.html')
const miningHtml = _$miningHtml;

@EmbedStr('/public/mining.js')
const miningJs = _$miningJs;

@EmbedStr('/public/projects.html')
const projectsHtml = _$projectsHtml;

@EmbedStr('/public/projects.js')
const projectsJs = _$projectsJs;

@EmbedStr('/public/solutions.html')
const solutionsHtml = _$solutionsHtml;

@EmbedStr('/public/solutions.js')
const solutionsJs = _$solutionsJs;

void loadPages(app) {
  app.get(
    '/logo.png',
    () => Response.ok(logoPng, headers: {'Content-Type': 'image/png'}),
  );

  rPage(app, "/about.html", aboutHtml);
  rCss(app, "/bulma.min.css", bulmaMinCss);
  rJs(app, "/chart.js", chartJs);
  rPage(app, "/config.html", configHtml);
  rJs(app, "/config.js", configJs);
  rPage(app, "/", indexHtml);
  rJs(app, "/index.js", indexJs);
  rPage(app, "/mining.html", miningHtml);
  rJs(app, "/mining.js", miningJs);
  rPage(app, "/projects.html", projectsHtml);
  rJs(app, "/projects.js", projectsJs);
  rPage(app, "/solutions.html", solutionsHtml);
  rJs(app, "/solutions.js", solutionsJs);
}

void rPage(var app, String url, var obj) {
  app.get(
    url,
    () =>
        Response.ok(obj, headers: {'Content-Type': 'text/html; charset=utf-8'}),
  );
}

void rCss(var app, String url, var cssContent) {
  app.get(
    url,
    () => Response.ok(
      cssContent,
      headers: {'Content-Type': 'text/css; charset=utf-8'},
    ),
  );
}

void rJs(var app, String url, var jsContent) {
  app.get(
    url,
    () => Response.ok(
      jsContent,
      headers: {'Content-Type': 'application/javascript; charset=utf-8'},
    ),
  );
}

