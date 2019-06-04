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
														<img src="data:image/png;base64,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" alt="coffee" width="254" height="168" />
													</xsl:if>
													<xsl:if test="//Title/@MessageType=1">
														<img src="data:image/png;base64,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" alt="clock" width="254" height="168" />
													</xsl:if>
													<xsl:if test="//Title/@MessageType=2">
														<img src="data:image/png;base64,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" alt="check" width="254" height="168" />
													</xsl:if>
													<xsl:if test="//Title/@MessageType=3">
														<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAP4AAACoCAYAAADAQVO7AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAABLYSURBVHgB7Z1ZbxRXGoaPbQzBZvECNpjVIQxBMERZlcwSiUhzM8nF3OXHzT+IRpqb3MxFhlGQJlHWCZhAYsBgHPCCDTbesMFMP8c5TrlcS29V3a7zPqh0qqvbdLtd77edreVFCSOE8IpWI4TwDglfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfxDI7O2sPUTwkfLGFp0+fmhs3bljR79+/34jiscMIEeDBgwdmdHTUHD582Bw/ftyIYiLhC8uzZ8/MzZs3zfT0tDl27JhEX3AkfGFD+6tXr9q2t7dXovcACd9zFhYWzNDQkPX4u3btMoODg0YUHxX3PCYoesDTI35RfCR8TyGsv379+oboEXxfX58RfiDhe4rL6R3K6/1CwveQe/fubRI9qL/eLyR8z0DwExMTW64rt/cLCd8zGI0X9vbCPyR8z5icnIy87op8wg8kfM+gC6+S66KYSPieEefZGaMv/EHC94wdO6IHayr39wsJ3zPiqvdEAszKE34g4XtGT09P7HMU/rTwhh9I+J7R39+f+Pzw8LAq/B4g4XsGoT6LbMThVt8RxUbC95C0WXiE+3H9/aIYSPgeQmX/9OnTia+R8IuNhO8pTMpJCvnx+sr1i4uE7zGE/HH9+rCysmJEMZHwPQbRJ3n91dVVI4qJhO85AwMDiV5fFBMJ33MQfdwiHC+99JIRxUTCF7HhvhbnKC4SvjCdnZ1brmkprmIj4Qsb7ofF39HRYURxkfCFJSx8dtQRxUXCF5a2traNc3J7hfrFRsIXlmCXnkRffCR8sQVtrlF8JHyxCby9uvGKT8uLEkZsC9yfanl52Q6nff78uT1nMg2P3Zp57jmuByfa8PNx6+oR6re2ttrXr62t2cfB8B9j0NLSsnHe3t5u6wK0vI7BPsEW3OtF8yHhNxn8ORAugp6fn7ft0tKSFSznWS2IiYChXuPzMQ4YAXfQa8B77Nmzx7YyCo1Fwm8gfPXMgHv8+LEVN1NhWd++Eavd7ty5c8PbZw1jBDAGGAFSi71799r3lzHIDwk/R5zQnzx5Yh4+fGiFvri4aBoNgiM8b+RsPIwBRuDAgQOmu7vbph0yBNkh4ecAXnRmZsZMTU1ZwTfbAhfk6nzGZrkVSBP27dtnTpw4YQ1CcIyBqA8SfoYgJvJ0Vq6dm5szzQrCohjYjLAc+ODgoK0RyADUDwk/I/DqrFt369atTDz8/OMJ075WKvrNTZrdbUtm/tGkaX+xZHaUDnixOGXbtaWp335odcG8WN2cWrR1nTQvVhbN2uL6Gnurz0rpyPMXZk93vz1fLZ3vfKnTtLR32Outuw/a6y0d6+2zXb1m194++5o93YdsW29IQ86cOWONgNYOqA8Sfga4brTvvvuu6kLdyvJCSczjZubBbTP/cMR0tCybtdk7JZEvm7aVadO5s9W076g9B25p7ywZg9o2zMQALKysmcWna+bh7Ko1BsttvdZ4dHb1m+7Dp8yerj7TU2qrBcG//fbbW7oZRXXoG8wAFzaXGz4j8pkHt8yj0jExctXMjN8qiX7CDHS3m1OHdpsTHW3rInfjanbUJ+RtLXnttcUpUyt8tq7SZ+oqfU4+szFEHWNmam7EjI6umB/+/ZvxQ/zdh182PYdeNv2DF8o2Bi7Mx6BK+LUjj58BhPgUp8jrf/rpp8hQf3zkSknk6wfnYf58dp85uK8YN/jU3Kq5fP1J5HOkBoj/1Ot/Mf0vXyhFBlt3+kHop06dsqE+PSFpuwGJdGQ6M+DmzZvm3LlzVvwXLlwwIyMj5tGjR9azX//vP+3BeTJ+2GO+h/GA8cMInH3vbxtGgO/wlVdesZV+0iZqJhJ+7WisfgZwg167ds16fm7YV1991bzxxhtm+eGweXz/pzJEb6yH/Ob2vPWW25HVZ2v2s385PB/r7aMg5fn2X383C/evWOPJwXdId+iVK1e0lXedUKifAZcuXdo456Y9evSo6evr27h2/+6w+fG7/5jv//MPc3voy7L+T8L+/aUc+sDedtOxq9V07qK41xx2G5EvlAp7s4vPS8cz2z4uHRT9ymXg5Fnzu9f+ZC784a/mxKtvmo4961ODCe3HxsY2dYdevHjRiNqQ8DPg8uXLW/J6DAAj0jAAwdVueN3ta1+an/932Yzdumqmx++W2qGy3scW1Sj8tbVYY9De1vpr27JR8V8/XzcQO9tMqrFAxCuBmuTi0+e/tmsb7eLK+vnswjPbxeeeK5fug0fM0VPnzSu//6M5ODBYEvwfTMe+3o2ReogdoY+Pj0fWRyT82pHwM+CLL76wE2ricCPTKFZhBMLTYBfnZ60RWJidMWO3h0rG4I6ZmRgz0xOjpfae2Q709h83Pf3HTO8h2uPmQKk98vJ5c+DwSbO75M2Dw3ERNzUQBjuljWxkjP97771nRG1I+BmQJvwwbtIKxgBDwOO4Liv+XItPHpmZyXtmqWQgpsdHraHgWLItz/2y/tq15+aROy/94zXLC+kjCNtLlfZ9+39bc699d6cNvdvadpiuA0dMW6nrjmr83tJrOvZ02ed6SsKmRdSIPg5EzUQk5ijQ4tkrydsl/Pqgqn4TgAg4KGA5ED4GgGiAA4PgrnXu67FHs4KQETi/kxM6BxOUtBFncyDhZwBeKc3ju22q8XjM1gvP0kMgSeP7nUHAGDC4xaULvDePXcQQPHc/Vw5hL+weu9aNTuSxWxCENuuqu3b3qQ8SfoNg/jneu6uryz5GROS4o6OjZYmH16hrS1SL+vEzoByvFJ5phlfGCGgGWjIarlsfJPwGEXcDy4snI+HXBwk/A6rx+I5mnRffLCjHrw8ynxngFq4U2UAdhHUKWdGI5cKChVHqJq52cvDgwdidgH1Hws8A5enZwBiG77//PvE1rmuUgUBMlsIIDwwMmLNnz2oj0AAK9TNg9+7dphqU3ydTTRpERHD37l3z+eef21asI+FngPLQbKil/kEU8O2335rr168boVA/E8qpPHMTh1MCbV2VTJTwCd/J5R1uOHDcsuUIn/CfOf4+I+FngFsXLml4Ks+pFlAZTvisvU/ezvLbcYVUcnxC+6jwHvHz8z7n/BJ+RhDuMxJP1A9qJ6+//roVfhq8hoOdfwnxgxEAeT/if/PNN42vKMfPCLaHSoIJK1Eo3I/n0KFDZYk+CGnA+++/v8W7379/v6E7BzUaCT8j0gp8quBXTpoxjQPRs/ZhEESP+H1Fws+INOHH5f9M3hHRsLlmtZDTh+sBrPTjKxJ+RrDMVhIK9Sun1m7ScLjfDBuWNgoJPyOq9fiq9MdTbajvCHv8OOPrAxJ+hiTdqHEVf3n8aGoVvdiMhJ8hSTerPH5l1EP44ZzeLYLiIxJ+hiQVo+KWqdJEkmjSaiZpMKAn3H0XHPHnGxJ+hqR5FNbaC6NQP5paPX7UCL5KxwQUCQk/Q7hZk8btR1WVgwtninX4DmsRPt8zc/eDJA339QEJP2OSvH6UxweF+5uph7cPG1mE7zMSfsYk5abcjFEzzjSIZzO1hOR8x+GpuKzK43OYDxJ+xlST58vjb6aWwt4PP/yw5dprr71mfEfCz5i0PD+4e46jlqGpRYOBUNWG+nj6Bw8ebLqmJbjWkfBzgFllcbBoZBiKe+rPX6favnYEHw7xETzCFxJ+LiT1F5PjR4X7bKApTFWr5FLM++abbzZdQ/RMzxXrSPg5gNdKCvfZIjqMwv31ML9Sj8/Kuiy8ER6s8+677yrEDyDh50RSuM+osnB13+fhpI5KvgOEfuXKFXuEYaUdfZ+bkfBzIi3cHx8f33TN7YbrM+WG+XTZsXw23j4Move9zz4KCT8n8DhJU3Wnp6cjf8ZXyg3zEftnn30WuaiGRB+PhJ8jSR6MCTuE/EFqnZiynRkcHEx8nt4QvDyhfTifZyjuBx98INEnoFV2c+To0aPm3r17sVNyWQMuOKKMAh/dej5upBnn7RE5Xj5uYwxXvVchLxkJP0eo7FPkGxsbi3wer0+uHywEcv7LL78Yn+B3jkqL6JtnJF7ckllskkE/vTYtTUfCz5ljx47FCh/w+hQC3QAePJ9vwg+H+aRAP/7445ZUyIF3f+utt7wff18JEn4OrK2tmaWlJeupWHKLGzXOaxHW375925w+fdo+5rWE/HEz+YoGvyv5Oy3fG7vjxgnebYXFIS9fGS0v2HtY1B1uWirN7OW2vLxsHzuiuu/CEBm4kB/R37hxw/gAvzPfz+TkZORwZgfLZbNWvnL56pDHrzN4drrmwmIPQhjf2dlpjUIchPxU9enLx/v54PWpgZDHJwme76HcbbREPPL4dQCBM+yWI07sUT8zMTGR+HpEf+bMGdsW3etT2Exa5x5j2dfXZ3p7e21YT4u3L2dnYrEVCb8GqhF8EPL9tN1cguJH+EX0+nx3/F5x36ETfHjGIgaAyUz79++XAagQCb9KEDshfTWCD0LhKm0fPSd+uHbtWuH69Ul5oja3IB06cuRI6opELgLQjMbykfArhAEkhOj12n7JFbLSDIgTP/nv6OioKQpRIT5CR/AIvxLYRpvRkfL+6Uj4FUDhjj71Wr18mHJCfgfVfoxPWq/AdoDvcW5uzrhbMJjHVwvev7+/X9X+FCT8MuEGzVJspA7lRhFurv52z/cxdogfwSP2qDy+WugWVOgfj2KiMnBDabOEAhV5btw4/iBFKPC57k6MGOF5vVcW5u9FyC/PH408fhkwkq4cQdYK+T7Fvjzeq5GQqnDbEdZXmsdXAmE/M/RaWzUJNYyEn0LWIX6Ycot92xW8MCE4hbg8cCmE2IxMYQpR6+FlCTkuo9KKWJnG8/b09OQmeqhX70vRkPBTSOtjzwJCVMRfpGAMQ0Zon/dkGnpixFYk/CaFFGNkZGTL6jLbEQp5P//8s/2dRHMg4aeQZ1gaZHh42Ir+zp07uacb9QSxs+oQvwuGLG+083A06s5Lge6gRoSLDOoBinwU+0g53ASV7QCfmx6KoNFKmnWXFT6vW5iEPH4K3DiNKLSFIw0Gu+A5yx3h10gwWlGRSt7e103iEVuR8FOgEp20GUZWRK3I64bqutC52aCCzmdjWHPU56tmO6xaYLEOEY368csET8vknLwgtGfgUNKcfXaRJSJp9Og0BM9MxbiuM4wn6wiyRFZeXl9DdpOR8CuAGxuPm9fIOt4P4ZMrJw3TDS5MkVcNAGNEzs6U2qS+clIWRJj1KD0HRgZPr6G6yUj4FeLC7bwKfhgZog0OvGraOH1ueATG8tT1vvkRuFs0NEnsiA/Bs0IwEQmDdvKok/D7YmQ0LTcdCb9K6KbKc1x90AAgOjwtIkwb2osYCK8RAxNhECVRASMEw2PY+b8YMkyLgWPSEAdpB23Se/F/8T4YHSYc0TIBJ4/Qnvcm4lEFv3wk/BpAHBgAxJinAXCLV9BiAGgxAu65PMCQ4NXd5p4IHcPCNc7zmBjDeyB2Dk3EqQwJvw5gABBeI2bWOW/M6Di8NS2fh88RbPHWQY8e572DYTKRAY+JDmidV+c6Iuec1p3nhQRfOxJ+naEPm6NRw1MRNGJH4LTu4M/sBF+u8J3oEZcTvjMGeQuO96NuQb1AhbvakfAzwkUBGADNEKsOJ3ZSB2eEJPr6IOFnCGPTET0bObrts2iLvtBGLRBRMD6BWgG35t27d83XX39tzz/++ONcugR9QMLPmEuXLplPP/3U9mO/88475vz587aby3WLkaM3Yupvs4DQETmenJZhvl999ZVdRpwDEPyHH35oRP2Q8HOASTaffPKJNQKAETh37pw9Tp48aZeHoijnqvOkCUUzBq4+4HoBOAjjKYgi8KGhIbsjLt8V4Nk/+ugjK3h5+foj4ecINzU3OUbA3eDAjY0BYHtojAHDWzl3C1JiBFxXHUU7V6VvNhA3ebir/JOXO7G7/QiYvMNBGkQb3j9Qgs8HCb9BYACIAGiDRiAI4icEpnXGgMesG4+3dINqXBXfDbwBV0dw18PnSYSH/brHruLPYydyJ27OMVRuZh6/09TUlG3d4zgQ+MWLF20qhOET2SPhNwEu1A3mtWkgFlIGDAFGgYIY51wD17ohvOBek0ZYpAg4eJ3WFSt5jgPPnbT7bxgETr3DpTwiXyT8JgPx4CExBC4sTvKW2wGMEKkMAidq4VxhfGOR8LcBzhiQF+Ndad21ZgEhu1oFQnepiUTenEj425ygAcAouA09XRjuXuMGEZUTkjsROxAxj0kTXLrg9qdzz7nUQmwPJHwhPEQzHITwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwEAlfCA+R8IXwkP8DeXgJrRHD4yYAAAAASUVORK5CYII=" alt="coffee" width="254" height="168" />
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