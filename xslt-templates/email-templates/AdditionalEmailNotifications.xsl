<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output	encoding="utf-8"
				  method="html"
				  indent="yes"
				  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
				  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

  <!--отображаемое имя из справочника сотрудников-->
  <xsl:template name="getdisplayname">
    <xsl:param name="lastname" select="."/>
    <xsl:param name="firstname" select="."/>
    <xsl:param name="middlename" select="."/>
    <xsl:param name="displaystring" select="."/>
    <xsl:if test="string-length($displaystring)!=0">
      <xsl:value-of select="$displaystring"/>
    </xsl:if>
    <xsl:if test="string-length($displaystring)=0">
      <xsl:value-of select="$lastname"/>
      <xsl:if test="string-length($lastname)!=0">
        <xsl:text></xsl:text>
      </xsl:if>
      <xsl:value-of select="$firstname"/>
      <xsl:if test="string-length($firstname)!=0">
        <xsl:text></xsl:text>
      </xsl:if>
      <xsl:value-of select="$middlename"/>
    </xsl:if>
  </xsl:template>

  <!-- сотрудник -->
  <xsl:template name="getemployeedisplayname">
    <xsl:param name="employeerow" select="."/>
    <xsl:call-template name="getdisplayname">
      <xsl:with-param name="lastname" select="$employeerow/@LastName"/>
      <xsl:with-param name="firstname" select="$employeerow/@FirstName"/>
      <xsl:with-param name="middlename" select="$employeerow/@MiddleName"/>
      <xsl:with-param name="displaystring" select="$employeerow/@DisplayString"/>
    </xsl:call-template>
  </xsl:template>

  <!--Конвертация даты в желаемый формат-->
  <xsl:template name="convertdate" match="text()" mode="replace">
    <xsl:param name="str" select="."/>
    <xsl:if test="string-length($str)>0">
      <xsl:copy-of select="substring($str, 9, 2)"/>
      <xsl:text>.</xsl:text>
      <xsl:copy-of select="substring($str, 6, 2)"/>
      <xsl:text>.</xsl:text>
      <xsl:copy-of select="substring($str, 1, 4)"/>
      <xsl:text> </xsl:text>
      <xsl:copy-of select="substring($str, 12, 2)"/>
      <xsl:text>:</xsl:text>
      <xsl:copy-of select="substring($str, 15, 2)"/>
    </xsl:if>
  </xsl:template>

  <!--Для сохранения переносов строки в тексте-->
  <xsl:template name="LFsToBRs">
    <xsl:param name="input" />
    <xsl:choose>
      <xsl:when test="contains($input, '&#10;')">
        <xsl:value-of select="substring-before($input, '&#10;')" />
        <br/>
        <xsl:call-template name="LFsToBRs">
          <xsl:with-param name="input" select="substring-after($input, '&#10;')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$input" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Комментарий последнего делегата-->
  <xsl:template name="delegatecomment">
    <xsl:for-each select="//*/DelegatesRow">
      <xsl:sort select="@Date" order="descending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="@Comment"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- письмо -->
  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    <html>
      <Head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>
          <xsl:value-of select="//Title/@Description"/>
        </title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <style type="text/css" media="all">
          <xsl:if test="//Title/@MessageType=0">
            .bg {
            background: #bbd02d;
            height: 100%;
            }
          </xsl:if>
          <xsl:if test="//Title/@MessageType=1">
            .bg {
            background: #173845;
            height: 100%;
            }
          </xsl:if>
          <xsl:if test="//Title/@MessageType=2">
            .bg {
            background: #173845;
            height: 100%;
            }
          </xsl:if>
          <xsl:if test="//Title/@MessageType=3">
            .bg {
            background: #bbd02d;
            height: 100%;
            }
          </xsl:if>
        </style>
      </Head>

      <body style="margin:0; padding:0">
        <table  align="center" border="0" cellpadding="0" cellspacing="0" width="100%" class="bg" style="border-collapse:collapse;">
          <tr>
            <td></td>
            <td width ="600">
              <table align="center" width="100%" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse;">
                <tr>
                  <td style="width: 16px;"></td>
                  <td height="90" align="center">
                    <xsl:if test="//Title/@MessageType=0">
                      <img src="data:image/png;base64,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" alt="Docsvision logo" width="200" height="42" />
                    </xsl:if>
                    <xsl:if test="//Title/@MessageType=1">
                      <img src="data:image/png;base64,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" alt="Docsvision logo" width="200" height="42" />
                    </xsl:if>
                    <xsl:if test="//Title/@MessageType=2">
                      <img src="data:image/png;base64,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" alt="Docsvision logo" width="200" height="42" />
                    </xsl:if>
                    <xsl:if test="//Title/@MessageType=3">
                      <img src="data:image/png;base64,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" alt="Docsvision logo" width="200" height="42" />
                    </xsl:if>
                  </td>
                  <td style="width: 16px;"></td>
                </tr>
                <tr>
                  <td style="width: 16px;"></td>
                  <td>
                    <table align="center" width="100%" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;width: 600px;max-width: 600px; background: #ffffff">

                      <!-- информация о замещении -->
                      <xsl:if test="//Employee/Hints/Deputy/@Employee">
                        <tr>
                          <td height="50" style="text-align: center;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 18px;padding: 3px 13px 3px 13px;background: #ffdd80;color: #382900;">
                            ЗАМЕЩЕНИЕ
                            <xsl:value-of select="//Employee/Hints/Deputy/@Employee"/>
                          </td>
                        </tr>
                      </xsl:if>

                      <!-- состояние -->
                      <xsl:if test="//Title/@MessageType=0">
                        <tr>
                          <td height="50">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse; ">
                              <tr>
                                <td style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;padding: 5px 13px 5px 13px;background: #258023;color: #ffffff ;text-align: center;white-space: nowrap;">
                                  Завершено
                                </td>
                                <td style="width: 40%;"></td>
                                <td align="right" style="padding-right: 10px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;text-align: right;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@Date"/>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </xsl:if>
                      <xsl:if test="//Title/@MessageType=1">
                        <tr>
                          <td height="50">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse; ">
                              <tr>
                                <td style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;padding: 5px 13px 5px 13px;background: #c50000;color: #ffffff ;text-align: center;white-space: nowrap;">
                                  Отклонено
                                </td>
                                <td style="width: 40%;"></td>
                                <td align="right" style="padding-right: 10px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;text-align: right;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@Date"/>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </xsl:if>
                      <xsl:if test="//Title/@MessageType=2">
                        <tr>
                          <td height="50">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse; ">
                              <tr>
                                <td style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;padding: 5px 13px 5px 13px;background: #19baff;color: #ffffff ;text-align: center;white-space: nowrap;">
                                  На приёмке
                                </td>
                                <td style="width: 40%;"></td>
                                <td align="right" style="padding-right: 10px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;text-align: right;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@Date"/>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </xsl:if>
                      <xsl:if test="//Title/@MessageType=3">
                        <tr>
                          <td height="50">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse; ">
                              <tr>
                                <td style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;padding: 5px 13px 5px 13px;background: #258023;color: #ffffff ;text-align: center;white-space: nowrap;">
                                  Завершено
                                </td>
                                <td style="width: 40%;"></td>
                                <td align="right" style="padding-right: 10px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;text-align: right;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@Date"/>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </xsl:if>

                      <!-- описание -->
                      <xsl:if test="//Title/@MessageType=0">
                        <td height="50" style="font-size: 20px;text-align: center;font-weight: bold;height: 50px;font-family: Roboto, Arial, Helvetica, sans-serif;">
                          Задание завершено
                        </td>
                      </xsl:if>
                      <xsl:if test="//Title/@MessageType=1">
                        <td height="50" style="font-size: 20px;text-align: center;font-weight: bold;height: 50px;font-family: Roboto, Arial, Helvetica, sans-serif;">
                          Задание отклонено
                        </td>
                      </xsl:if>
                      <xsl:if test="//Title/@MessageType=2">
                        <td height="50" style="font-size: 20px;text-align: center;font-weight: bold;height: 50px;font-family: Roboto, Arial, Helvetica, sans-serif;">
                          Задание на приёмке
                        </td>
                      </xsl:if>
                      <xsl:if test="//Title/@MessageType=3">
                        <td height="50" style="font-size: 20px;text-align: center;font-weight: bold;height: 50px;font-family: Roboto, Arial, Helvetica, sans-serif;">
                          Группа заданий завершена
                        </td>
                      </xsl:if>


                      <!-- картинка -->
                      <tr>
                        <td align="center">
                          <xsl:if test="//Title/@MessageType=0">
                            <img src="data:image/png;base64,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" alt="coffee" width="120" height="128" />
                          </xsl:if>
                          <xsl:if test="//Title/@MessageType=1">
                            <img src="data:image/png;base64,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" alt="clock" width="166" height="132" />
						  </xsl:if>
                          <xsl:if test="//Title/@MessageType=2">
                            <img src="data:image/png;base64,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" alt="check" width="256" height="169" />
						  </xsl:if>
                          <xsl:if test="//Title/@MessageType=3">
                            <img src="data:image/png;base64,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" alt="coffee" width="120" height="128" />
                          </xsl:if>
                        </td>
                      </tr>

                      <!-- отступ -->
                      <tr>
                        <td height="10"></td>
                      </tr>

                      <!-- информация о задании -->
                      <tr>
                        <td style="padding-left: 20px;padding-right: 20px;">
                          <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                            <!-- на исполнение -->
                            <xsl:if test="//Data/CardTask/@Description">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">На исполнение:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <a style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;">
                                    <xsl:attribute name="href">
                                      <xsl:value-of select="//Employee/AdditionalInfo/OpenCard/@Link"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="//Data/CardTask/@Description"/>
                                  </a>
                                </td>
                              </tr>
                            </xsl:if>
                            <xsl:if test="//Data/CardTaskGroup/@Description">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">На исполнение:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <a style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;">
                                    <xsl:attribute name="href">
                                      <xsl:value-of select="//Employee/AdditionalInfo/OpenCard/@Link"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="//Data/CardTaskGroup/@Description"/>
                                  </a>
                                </td>
                              </tr>
                            </xsl:if>
                            <!-- автор -->
                            <xsl:if test="//Data/CardTask/MainInfo/@Author">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Автор:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:variable name="authorId" select="//Data/CardTask/MainInfo/@Author"/>
                                  <xsl:call-template name="getemployeedisplayname">
                                    <xsl:with-param name="employeerow" select="//*/EmployeesRow[@RowID=$authorId]"/>
                                  </xsl:call-template>
                                </td>
                              </tr>
                            </xsl:if>
                            <xsl:if test="//Data/CardTaskGroup/MainInfo/@Author">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Автор:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:variable name="authorId" select="//Data/CardTaskGroup/MainInfo/@Author"/>
                                  <xsl:call-template name="getemployeedisplayname">
                                    <xsl:with-param name="employeerow" select="//*/EmployeesRow[@RowID=$authorId]"/>
                                  </xsl:call-template>
                                </td>
                              </tr>
                            </xsl:if>
                            <!-- исполнители -->
                            <xsl:if test="//Data/CardTask/MainInfo/Performers/PerformersRow">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Исполнители:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:for-each select="//Data/CardTask/MainInfo/Performers/PerformersRow">
                                    <xsl:value-of select="current()/@EmployeeDisplayString"/>
                                    <xsl:if test="position() != last()">
                                      <xsl:text>, </xsl:text>
                                    </xsl:if>
                                  </xsl:for-each>
                                </td>
                              </tr>
                            </xsl:if>
                            <xsl:if test="//Data/CardTaskGroup/MainInfo/Performers/PerformersRow">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Исполнители:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:for-each select="//Data/CardTaskGroup/MainInfo/Performers/PerformersRow">
                                    <xsl:value-of select="current()/@EmployeeDisplayString"/>
                                    <xsl:if test="position() != last()">
                                      <xsl:text>, </xsl:text>
                                    </xsl:if>
                                  </xsl:for-each>
                                </td>
                              </tr>
                            </xsl:if>
                            <!-- контролёр -->
                            <xsl:if test="//Data/CardTask/MainInfo/@Controller">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Контролёр:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:variable name="controllerId" select="//Data/CardTask/MainInfo/@Controller"/>
                                  <xsl:call-template name="getemployeedisplayname">
                                    <xsl:with-param name="employeerow" select="//*/EmployeesRow[@RowID=$controllerId]"/>
                                  </xsl:call-template>
                                </td>
                              </tr>
                            </xsl:if>
                            <xsl:if test="//Data/CardTaskGroup/MainInfo/@Controller">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Контролёр:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:variable name="controllerId" select="//Data/CardTaskGroup/MainInfo/@Controller"/>
                                  <xsl:call-template name="getemployeedisplayname">
                                    <xsl:with-param name="employeerow" select="//*/EmployeesRow[@RowID=$controllerId]"/>
                                  </xsl:call-template>
                                </td>
                              </tr>
                            </xsl:if>
                            <!-- срок до -->
                            <tr>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Срок до:</td>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                <xsl:variable name="enddate" select="//Data/CardTask/MainInfo/@EndDate"/>
                                <xsl:choose>
                                  <xsl:when test="string-length($enddate)>0">
                                    <xsl:call-template name="convertdate">
                                      <xsl:with-param name="str" select="//Data/CardTask/MainInfo/@EndDate"/>
                                    </xsl:call-template>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:text>
																			не указан
																			</xsl:text>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </td>
                            </tr>
                            <!-- дата контроля -->
                            <xsl:if test="//Data/CardTask/MainInfo/@ControlDate">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Контролёр:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:variable name="controlDate" select="//Data/CardTask/MainInfo/@ControlDate"/>
                                  <xsl:choose>
                                    <xsl:when test="string-length($controlDate)>0">
                                      <xsl:call-template name="convertdate">
                                        <xsl:with-param name="str" select="//Data/CardTask/MainInfo/@ControlDate"/>
                                      </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:text>
																					не указан
																				</xsl:text>
                                    </xsl:otherwise>
                                  </xsl:choose>
                                </td>
                              </tr>
                            </xsl:if>
                            <xsl:if test="//Data/CardTaskGroup/MainInfo/@ControlDate">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Контролёр:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:variable name="controlDate" select="//Data/CardTaskGroup/MainInfo/@ControlDate"/>
                                  <xsl:choose>
                                    <xsl:when test="string-length($controlDate)>0">
                                      <xsl:call-template name="convertdate">
                                        <xsl:with-param name="str" select="//Data/CardTaskGroup/MainInfo/@ControlDate"/>
                                      </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:text>
																					не указан
																				</xsl:text>
                                    </xsl:otherwise>
                                  </xsl:choose>
                                </td>
                              </tr>
                            </xsl:if>
                            <!-- отступ -->
                            <tr>
                              <td height="20"></td>
                            </tr>
                          </table>
                        </td>
                      </tr>

                      <!-- описание -->
                      <tr>
                        <td style="padding-left: 20px; padding-right:20px;">
                          <xsl:value-of select="//Title/@Description" disable-output-escaping="yes"/>
                        </td>
                      </tr>

                      <!-- отступ -->
                      <tr>
                        <td height="20"></td>
                      </tr>

                    </table>
                  </td>
                </tr>

                <!-- подвал -->
                <xsl:if test="//Title/@MessageType=0">
                  <tr>
                    <td style="width: 16px;"></td>
                    <td style="font-size: 11px;font-family: Roboto, Arial, Helvetica, sans-serif;line-height: 140%;color: #000000;padding-top: 15px;padding-bottom: 80px;">
                      Вы получили это письмо, поскольку являетесь зарегистрированным пользователем Docsvision и адрес
                      <a class="link" style="font-size: 11px; color: #000000">
                        <xsl:attribute name="href">
                          mailto:<xsl:value-of select="//Employee/@Email"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="//Employee/@Email"></xsl:value-of>
                      </a>
                      указан в настройках справочника сотрудников. Для изменения настроек уведомлений обратитесь, пожалуйста, к администратору системы.
                    </td>
                    <td style="width: 16px;"></td>
                  </tr>
                </xsl:if>
                <xsl:if test="//Title/@MessageType=1">
                  <tr>
                    <td style="width: 16px;"></td>
                    <td style="font-size: 11px;font-family: Roboto, Arial, Helvetica, sans-serif;line-height: 140%;color: #ffffff;padding-top: 15px;padding-bottom: 80px;">
                      Вы получили это письмо, поскольку являетесь зарегистрированным пользователем Docsvision и адрес
                      <a class="link" style="font-size: 11px; color: #ffffff">
                        <xsl:attribute name="href">
                          mailto:<xsl:value-of select="//Employee/@Email"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="//Employee/@Email"></xsl:value-of>
                      </a>
                      указан в настройках справочника сотрудников. Для изменения настроек уведомлений обратитесь, пожалуйста, к администратору системы.
                    </td>
                    <td style="width: 16px;"></td>
                  </tr>
                </xsl:if>
                <xsl:if test="//Title/@MessageType=2">
                  <tr>
                    <td style="width: 16px;"></td>
                    <td style="font-size: 11px;font-family: Roboto, Arial, Helvetica, sans-serif;line-height: 140%;color: #ffffff;padding-top: 15px;padding-bottom: 80px;">
                      Вы получили это письмо, поскольку являетесь зарегистрированным пользователем Docsvision и адрес
                      <a class="link" style="font-size: 11px; color: #ffffff">
                        <xsl:attribute name="href">
                          mailto:<xsl:value-of select="//Employee/@Email"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="//Employee/@Email"></xsl:value-of>
                      </a>
                      указан в настройках справочника сотрудников. Для изменения настроек уведомлений обратитесь, пожалуйста, к администратору системы.
                    </td>
                    <td style="width: 16px;"></td>
                  </tr>
                </xsl:if>
                <xsl:if test="//Title/@MessageType=3">
                  <tr>
                    <td style="width: 16px;"></td>
                    <td style="font-size: 11px;font-family: Roboto, Arial, Helvetica, sans-serif;line-height: 140%;color: #000000;padding-top: 15px;padding-bottom: 80px;">
                      Вы получили это письмо, поскольку являетесь зарегистрированным пользователем Docsvision и адрес
                      <a class="link" style="font-size: 11px; color: #000000">
                        <xsl:attribute name="href">
                          mailto:<xsl:value-of select="//Employee/@Email"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="//Employee/@Email"></xsl:value-of>
                      </a>
                      указан в настройках справочника сотрудников. Для изменения настроек уведомлений обратитесь, пожалуйста, к администратору системы.
                    </td>
                    <td style="width: 16px;"></td>
                  </tr>
                </xsl:if>
              </table>
            </td>
            <td></td>
          </tr>
        </table>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>