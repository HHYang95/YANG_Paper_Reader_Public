# YANG Paper Reader: Standalone Manual

**Stable Windows release: 0.1.3.** This manual describes the standalone program. Confirm download availability on the matching official release page; the manual does not establish completed installation on your PC.

This manual tells you, action by action, what to click, what the Reader then shows, what leaves your PC, and what to do when it stops.
Start with [README.md](README.md) and [INSTALL_GUIDE.md](INSTALL_GUIDE.md) in the official public repository. The installer verifies and places the protected program, then prepares its runtime; you start the Reader yourself after successful setup. No private source build or manual program-archive handoff is required.
Read LICENSE.txt, NOTICE.txt and THIRD_PARTY_NOTICES.txt in the installed program folder. The application and its minimal readable startup files retain the application terms; the independent public installer has its own AGPL-3.0-or-later [license](install/COPYING) and [scope](install/LICENSE-SCOPE.md).
Opening a paper and using its AI features are separate choices after installation.
Every request to the AI runs on your own account, through the Claude Code or Codex program you signed in to, and counts on that account.

## 1. Open a paper

Do: click Open PDF in the left panel and choose a PDF of at most 200 pages from a local folder.

You see: Preparing Page Layout until the layout of every page is ready; then you can read. The footer reads Background Parsing, then Tools Ready. The Summary appears under Summary in Assistance & Notes.

Sent: the text of every page goes to your own AI account for the Summary, once per paper. After the full parsing, one more automatic request sends the parsed text of every page together with that Summary, and the image of each Figure that a note of the Summary names (and of such a Table or Equation whose parsed text is unclear), to check that Summary and fill what it lacks. The paper's DOI goes to Crossref (api.crossref.org); where the first page and the PDF's details hold none, the one DOI printed on the last page goes instead, and without any DOI the title, first author and year go; once Crossref matches the paper, the journal's name goes to lab.peptide.ink. Nothing is sent for the parsing.

If it stops: Layout Preparation Needs Attention: click Retry Layout. A PDF in a linked or network folder is not opened: copy it to a local folder.

## 2. Reopen a paper or open another

Do: click Recent PDFs in the left panel and choose a paper, or drag one PDF file onto the window and drop it there.

You see: Recent PDFs lists up to 10 papers you opened, newest first, each with its recorded opening time when available. The current paper counts toward the ten and is marked Currently open. Select another available paper to switch. A paper you opened before comes back at the page where you stopped, with its notes and answers. Dragging a PDF over the window shows Drop to Open PDF. If the Reader is still working on the open paper, Open Another PDF asks first: Stop Work and Open stops that work and opens the new file; Go Back changes nothing. A new file that looks like a paper you opened before asks Possible Earlier Version of This Paper: Reference Earlier Results adds the earlier paper under Related Records in Paper Information, where its button opens the earlier results, read only; Open Separately opens the file on its own, and Cancel opens nothing.

Sent: a paper you open for the first time sends what section 1 names. A paper you opened before sends the Crossref and lab.peptide.ink lookup of section 1 again; its Summary is not sent again once it has been tried. If the paper is parsed again, one more automatic request may check its Summary against the new parsing.

If it stops: a row marked File Unavailable cannot be opened: use Open PDF. If the file has moved, Original PDF Moved offers Open Preserved Copy, the copy the Reader kept when you first opened it. Recent PDF Unavailable says why a paper could not open. Dragging anything other than one PDF over the window shows Cannot Open This File. A dropped file whose name does not end in .pdf is not opened, and the footer reads Drop one PDF file.

## 3. Read and move around

Do: scroll the pages, or use the Previous page and Next page arrows and the page number box above the page. Choose a zoom from 50% to 200%, click Fit Width, or hold Ctrl and turn the mouse wheel. Click an entry under Contents in the left panel, or a link in the PDF, to jump there; Back (Alt+Left), beside the page number, returns to where you were. Press Ctrl+F to search the text of the pages.

You see: the bar Find in PDF counts the matches of what you type (at least 2 characters) and reads No Matches when there are none; Enter and Shift+Enter step through the matches and Escape closes the bar. Contents lists the PDF's own outline, or else the title and the sections the layout found, each with its page. The button on the edge of the left panel (Collapse document panel) folds the panel away. The Reader keeps your page, scroll place and zoom for the next time you open the paper.

Sent: Nothing. A web link you click in the PDF opens in your web browser.

If it stops: while Preparing Page Layout shows, the pages are locked: see section 1. If a link cannot open, the footer says Link unavailable with the reason. If the reading place cannot be saved, the footer says so; Queue & Program Status (section 10) gives the reason.

After full Background Parsing, select **Parsed Text** in the reading toolbar. Choose a page to view its passages. **Copy Reading** copies the displayed text. When a spelling can be verified in the same passage of the original PDF, the reading shows the supported spelling and **Compare parsed text** reveals the earlier reading. An uncertain passage shows the parser text and offers **View Original** at its PDF location.

## 4. Paper Information and the 5-Sentences Summary

Do: click Paper Information in the left panel. Click 5-Sentences Summary, below it, to read the paper's Summary in five sentences.

You see: Paper Information shows the title, the authors, the journal, the year and the DOI, then Citations, Impact Factor and Quartile, with the source and retrieval date. The impact factor and quartile each identify Peptide Tools as the web source and show their own metric year when available. The retrieval date and report publication year do not supply a missing metric year. Open Categories to see which fields a quartile covers. Copy Title copies the title. Choose BibTeX, APA, Vancouver or Harvard and click Copy Citation to copy the citation; Citation Preview shows it first. When the PDF has no DOI, the Reader can use the printed title and byline on page 1 and the issue year on page 2. It fills a missing DOI or journal only when one Crossref candidate matches the title, complete author list and year. Refresh looks the paper up again. 5-Sentences Summary shows the Summary's stage, such as Preparing Source for Summary..., Preparing Paper Summary... or Generating Paper Summary..., until the Summary is ready, then shows its five sentences; a click opens them in a window of their own.

Sent: Refresh (Retry after a failed lookup) sends the lookup of section 1 again: the DOI, or the details section 1 names, to Crossref (api.crossref.org), and the journal's name to lab.peptide.ink once Crossref matches the paper. Opening Paper Information can start the same lookup when none has finished for the paper's current details. Copy Title, Copy Citation and 5-Sentences Summary send nothing. A link you click here (Crossref, Publisher or the journal's metrics page) opens in your web browser.

If it stops: Citations that read Unmatched, with "No confident Crossref match.", mean that Crossref did not confirm the paper: check the DOI in the PDF, then click Refresh. Citations that read Unavailable, with "Crossref unavailable." or "Metrics unavailable.", mean that the lookup got no answer: check the internet connection, then click Retry. If the Summary failed, 5-Sentences Summary reads Summary Needs Attention: click it to read why, then use the button it offers (View Summary Request, Open AI Settings, Retry Parsing or Open PDF Again). If Reader confirms that the selected runtime was missing or could not sign in, fix the installation or sign-in, then choose Retry Paper Summary. This sends one new request for this PDF to the runtime you selected. Reopening the PDF does not send the retry. See NOTICE.txt, item 4.

In BibTeX, the entry key uses the available first author, publication year and first title word, followed by a short identifier derived from the DOI or, when a DOI is unavailable, the PDF fingerprint. Preview and copy use the same key. A later metadata lookup can fill missing parts of the key in subsequent copies.

## 5. Select text: Translate, Ask, Highlight, Note

Do: select text in the PDF with the mouse. A small bar appears above it: click Translate, Ask, Highlight or Note.

You see: Translate adds a card under Translate in Assistance & Notes, with the selection translated into the Answer Language of AI Settings. Ask opens Ask About This Source: type your question and press Enter, or press Tab to fill in the suggested question "Explain this source in plain language." and press Enter; the answer comes as a card under Explanation, and the notice "Explanation completed." offers Open. Highlight marks the text, and Note opens Source Note for a note you save with Enter; both go under Notes. All shows written notes, manual highlights and automatic highlights in page order. Choose Written Notes, Manual Highlights or Auto Highlights to narrow the list. Search applies within the selected filter. Opening another PDF starts its Notes list at All. While a request runs, its card and the footer show its stage, and Cancel on the card stops it.

Sent: Translate sends the text you selected together with its image cut from the page. Ask sends your question and the text you selected: before the full parsing also its image and the paragraphs around it, as text and images; after the full parsing the parsed text around it and the image of a Figure it lies in or names (or of such a Table or Equation whose parsed text is unclear). All go to your own AI account. A request may add one more request with more source from the same PDF, which can include whole pages of the PDF as images. Highlight and Note send nothing.

If it stops: Request Could Not Start, at the top of Assistance & Notes, gives the reason, with Retry and Dismiss. A card that reads The AI Request Could Not Finish or The Request Could Not Finish: open it, read the reason, check the runtime in AI Settings if the reason names it, then click Retry. Closing the Reader follows its confirmation dialogs; after you choose to exit, it cleans up running requests, Auto Highlight passes and parsing. If a question or note is unsent, closing the Reader asks first (Unsent Draft: Discard and Close, or Cancel to keep it), and so does a click outside the editor (Discard, or Keep Editing); the editor's Cancel, its close mark and Escape close it and drop the text without asking.

## 6. Sections, Figures, Tables and Equations

Do: point at a section heading and click the small logo button beside it, then Summary or Ask; Ask on a section appears after the full parsing. Point inside a Figure, Table or Equation: a bar shows Ask, LaTeX (for an Equation), Copy Image, Save Image and Export Data (for a Table).

You see: Summary adds a card under Summary. Ask opens Ask About This Source as in section 5 and answers under Explanation. LaTeX and Export Data add a card under Others; its Request Details shows the LaTeX with a preview, Copy LaTeX, Copy Image and Save Image, or the table with Save CSV and Save JSON. Copy Image and Save Image copy or save the element's picture as cut from the page. Once a Figure, Table or Equation has answers, a small box beside it on the page opens them; you can drag the box aside.

Sent: Summary sends the text of that section. Ask on a section sends its parsed text and the image of each Figure in it or named in it (and of such a Table or Equation whose parsed text is unclear); Ask on a Figure, Table or Equation sends its image with its caption, the paragraphs that refer to it and the paragraphs around it, as text and images. LaTeX sends the Equation's image with the source the request needs, and after the full parsing also its parsed text. Export Data sends the Table's image cut from the page, with the source the request needs. All go to your own AI account. Except for Summary and LaTeX, a request may add one more request with more source from the same PDF, which for a Figure, Table or Equation can include whole pages of the PDF as images. Copy Image, Save Image and the box send nothing.

If it stops: Section Is Still Being Prepared: wait until the layout of every page is ready, then use the action again. A save into a linked or network folder is refused: choose a local folder. The Reader never replaces a file: if the name exists, choose another. A failed request: as in section 5.

After full parsing, open **Details → Background Processing → Equation transcriptions** to see the parsed math and jump to its original PDF position. Reader can correct a single kind of symbol confusion, between Latin y and Greek gamma, when the surrounding math corresponds uniquely to embedded text in the same region. A request to check the original means that the transcription has insufficient evidence. A correction applies to the indicated symbols only.

A saved LaTeX result shows the same reading in its preview and text. **Include printed equation number** adds a confirmed number to the preview, copied text and PNG. **Original transcription** opens the saved response before a symbol correction. **View Source** opens the original PDF region. These comparisons and exports run locally.

When a Section Summary response arrives, Reader checks its format and source citations before saving it. A single code block around the response is accepted. If Reader cannot read the response or match its citations to the paper, the reading record explains the reason. Choosing Retry sends a new request to the selected AI provider and may incur a charge.

## 7. Answers and notes in Assistance & Notes

Do: click Summary, Explanation, Translate, Notes or Others above the list, or type in Search Answers and Notes. Click a card to open Request Details. Reset, beside the Assistance & Notes title, clears this paper's reading records.

You see: Request Details shows the answer and moves the PDF behind it to the source. View Source closes it and goes to the source; Back to Record in the footer opens it again. A source number in an Explanation or Summary shows its PDF page and the kind of evidence saved with the answer. Click it to highlight the quoted passage when the Reader finds exactly one supported location in the original PDF. If the quotation repeats, is missing or cannot be located precisely, the Reader opens the original saved range. Citation navigation runs locally and uses existing answers. Continue Conversation asks a follow-up on the same source; on a note or highlight it opens New Conversation, and Edit changes a note. Continue Research appears when an answer reports missing source and asks the AI to look further. Copy Markdown copies the answer; Delete Card removes a card, Delete Turn removes one turn of an Explanation, and Delete Conversation removes a whole conversation after it asks. Reset asks first (Reset Reading Records): Reset Records clears, Cancel keeps everything; what it keeps is in NOTICE.txt, item 5.

Sent: Continue Conversation and New Conversation send your question, and Continue Research a set question, with the earlier turns, or with the earlier answer or the note the conversation starts from, and the source of that record from the PDF; for the paper's Summary that source is the text of every page. A request may add one more request with more source from the same PDF. Retry sends a failed or stopped request again. All go to your own AI account. Everything else here sends nothing.

If it stops: open the card and read the reason. An Explanation shows it under Latest Answer; any other card shows it in its notice or under Sources, Limitations & Details. Start a New Conversation means that the conversation has grown too long: click New Conversation. If Save Failed shows under the Assistance & Notes title, or the footer reads Reset failed, read the reason in the footer and try again. For the whole-paper summary, Retry Paper Summary is available once after a confirmed sign-in or runtime failure (NOTICE.txt, item 4).

## 8. Auto Highlight

Do: after the full parsing (the footer reads Tools Ready, or Summary Update while the automatic Summary update runs), click Auto Highlight in the toolbar above the page. Once highlights are saved, Add Highlights beside it, with its count out of 30 in brackets, runs one more pass.

You see: the button reads Cancel Highlight while the first pass runs. Up to three passes run one after another and mark up to 30 passages in the colours of Novelty, Methods and Results. Each passage gets a card marked Auto under Notes. From the end of the first pass the button reads Delete Auto Highlight, also while passes 2 and 3 run. A click on it stops any running pass and removes the automatic set and its cards at once, without asking, and keeps your own marks. To stop pass 2 or 3 alone, click Cancel Highlight under Highlight Passes in Queue & Program Status. Queue & Program Status shows the running pass under Request Queue or Highlight Passes, and the result under Auto Highlight.

Sent: each pass sends the full parsed text of the paper to your own AI account. The first click runs up to three passes; Add Highlights runs one. Cancel Highlight and Delete Auto Highlight send nothing.

If it stops: if it cannot start, the footer says Auto Highlight could not proceed, with the reason. A pass that fails reads Failed with its reason under Auto Highlight in Queue & Program Status, with the passages it could not place. Cancel Highlight stops a pass and keeps the highlights already saved. Click Auto Highlight again while no set is saved, or Add Highlights when one is.

## 9. HTML Overview

After Background Parsing finishes, click **HTML Overview**, choose the export folder, check the paper folder name, and click **Make HTML Overview**. Use **Open** to view the saved page. The paper information, contents, figures, tables and equations come from the open paper. Page numbers and regions identify their source. For an uncertain formula, compare the transcription with the original crop.

The export works offline and makes zero AI requests. Personal notes, highlights and saved summaries stay in the Reader. Keep the entire output folder together when sharing the HTML and its images.

If parsing is still running, the dialog shows what it is waiting for. If it has stopped, open **Details** and use **Retry Parsing**. If the destination is unavailable, use **Choose Folder** and select a writable local folder.

## 10. AI Settings, Queue & Program Status and Clear Parsing Data

On first use, Reader selects Codex if both supported programs are detected. If exactly one is available, Reader selects it. If neither is available, AI Settings shows how to install one. Reader keeps an explicitly saved runtime selection. You can change it in AI Settings.

Do: click AI Settings in the footer to choose the Runtime, Model, Effort and Answer Language, then click Save. Click the status at the left of the footer (it ends in Details) to open Queue & Program Status. Click Clear Parsing Data in the footer to see and clear the stored parsing data.

You see: AI Settings says whether the runtime is Available and lists, under Where the Reader Looked, every place it checked. Queue & Program Status shows Background Processing with Stop Background Parsing or Retry Parsing, then the Request Queue, the Automatic Summary Update and the Highlight Passes, each running item with Cancel or Cancel Highlight, and Runtime & Source Details. Clear Parsing Data lists each paper with its Size and Last Opened: Clear Current PDF clears the open paper's data at once; Clear All Parsing Data asks first. To clear some papers, tick them in the list (or click their rows), then click Delete Selected, which asks first for two or more papers. Search Papers narrows the list, and Refresh Size measures the data again. Original PDFs, notes and conversations stay, and a cleared paper is parsed again the next time it opens.

Sent: Nothing for AI Settings, Queue & Program Status or Clear Parsing Data; checking which program version is installed sends nothing, and the parsing runs on your PC. When a parsing started with Retry Parsing completes, the automatic Summary update of section 1 follows if it has not run for that parsing, and sends what section 1 names to your own AI account; the Crossref lookup of section 1 may run again.

If it stops: if the runtime is Unavailable, Save stays disabled: open Where the Reader Looked, install or update Claude Code or Codex (INSTALL_GUIDE.md, section 2), sign in, and open AI Settings again. Parsing Needs Attention: read the reason in Queue & Program Status and click Retry Parsing. If Clear Parsing Data says that parsing or assistance is still active, wait for it to finish, then clear again.
