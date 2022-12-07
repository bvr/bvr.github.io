<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sm="http://www.sitemaps.org/schemas/sitemap/0.9" exclude-result-prefixes="sm">
<xsl:output method="html" encoding="utf-8" indent="yes" />
<xsl:template match="/sm:urlset">
<ul>
  <xsl:for-each select="sm:url/sm:loc">
    <li><a href="{.}"><xsl:value-of select="." /></a> <xls:value-of select="lastmod"/></li>
  </xsl:for-each>
</ul>
</xsl:template>
</xsl:stylesheet>
