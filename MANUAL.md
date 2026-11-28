# YANG Paper Reader: Standalone Manual

**Stable Windows release: 0.2.2.** This manual describes the standalone program.

- Start with [README.md](README.md) and [INSTALL_GUIDE.md](INSTALL_GUIDE.md) in the official public repository.
- Every AI request runs on your own account, through the Claude Code or Codex program you signed in to, and counts on that account.
- This manual is also installed as MANUAL.html; User Manual, in the Start menu and the Information dialog, opens it in your web browser.
- Read LICENSE.txt, NOTICE.txt and THIRD_PARTY_NOTICES.txt in the program folder; the Setup's script has its own AGPL-3.0-or-later [license](install/COPYING) and [scope](install/LICENSE-SCOPE.md).

## 1. Open a paper

### Open PDF

Opens and parses a paper.

1. Click Open PDF in the left panel, or press Ctrl+O.
2. Choose a PDF from a local folder.

- Preparing Page Layout shows until every page is ready; then you can read.
- The footer reads Background Parsing, then Tools Ready; the parsing runs on your PC.
- **Sent:** the DOI, or else the title, first author and year, to Crossref (api.crossref.org); once matched, the journal's name to lab.peptide.ink.
- **Limit:** a PDF of more than 200 pages, or in a linked or network folder, is not opened.
- **If it stops:** at Layout Preparation Needs Attention, click Retry Layout.

### Paper Summary

Your AI summarizes each new paper.

1. Leave Start the Paper Summary by itself on in General Settings, as at first.

- The Paper Summary appears as a card under Summary in Assistance & Notes.
- After the full parsing, one Summary Update checks it and fills what it lacks.
- **Sent:** every page's text without page images, once per paper; at the Summary Update, the Paper Summary and the parsed text.
- **Sent:** at the Summary Update, images of Figures the Paper Summary's notes name, and of such Tables or Equations whose parsed text is unclear.
- **Limit:** the Paper Summary, the Summary Update and Auto Highlight refuse a paper of more than 48 pages before sending anything.

## 2. Reopen a paper or open another

### Recent PDFs

Reopens a paper where you stopped, with its notes and answers.

1. Click Recent PDFs in the left panel.
2. Choose a paper, or find one by title, author or file name in Search Recent PDFs.

- It lists up to 10 papers, newest first; the search also finds older ones.
- **Sent:** the lookup of section 1 again; a Paper Summary once tried does not start again by itself.
- **If it stops:** for File Unavailable, use Open PDF; if the file moved, choose Open Preserved Copy.

### Open Another PDF

Opens another PDF while one is open.

1. Drop one PDF file on the window, or use Open PDF or Recent PDFs.
2. If the Reader is still working, choose Stop Work and Open to stop its running work and open the chosen PDF, or Go Back to keep the current PDF and its work running.

- If parsing remains stopped when you return to a paper, open **Workspace** and choose **Retry Parsing**.

- **Limit:** dragging anything but one PDF file shows Cannot Open This File.

## 3. Read and move around

Nothing here is sent; a web link you click in the PDF opens in your web browser.

### Reading toolbar

Turns pages and zooms.

1. Use the Previous page and Next page arrows or the page number box, or scroll.
2. Choose a zoom from 50% to 200%, or click Fit Width.

- Ctrl+Plus and Ctrl+Minus zoom one step; Ctrl+0 sets Fit Width.
- The Reader keeps your page, scroll place and zoom for the next time.

### Contents

Jumps to a part of the paper.

1. Click an entry under Contents in the left panel, or a link in the PDF.
2. Click Back (Alt+Left), beside the page number, to return.

- Contents lists the PDF's outline, or else the title and sections the layout found, with their pages.

### Find in PDF

Finds words on the pages.

1. Press Ctrl+F and type at least 2 characters.
2. Press Enter or Shift+Enter to step through the matches; Escape closes the bar.

- **Limit:** a page with no embedded text, such as a scanned page, cannot be searched or selected: use Parsed Text.

### Parsed Text

Shows the text the parsing read.

1. After the full parsing, select Parsed Text in the reading toolbar and choose a page.
2. Click Copy Reading to copy a passage's text, its mathematics as LaTeX.

- An uncertain passage offers View Original at its PDF location.
- When the Reader can isolate a word difference, expand Compare a word that differs in the PDF text layer to see the parsed phrase and the PDF text-layer phrase. Opening this comparison does not change Copy Reading.
- The PDF text layer can itself contain OCR errors. Use View Original to check the printed word; the comparison is not offered for every mismatch.

## 4. Paper Information and the 5-Sentences Summary

### Paper Information

Shows the paper's details, citations and metrics.

1. Click Paper Information in the left panel.
2. Click Copy Title, or Copy Citation after choosing BibTeX, APA, Vancouver or Harvard.

- It lists the title, authors, journal, year and DOI, then Citations, Impact Factor and Quartile with their source.
- **Sent:** opening Paper Information can start the lookup of section 1 when none has finished for the paper's current details.
- **Sent:** Refresh repeats the lookup of section 1; a link here opens in your web browser.
- **If it stops:** for Unmatched, check the PDF's DOI; for Unavailable, the connection; click Retry or Refresh. Still Unavailable: the source has none.

### 5-Sentences Summary

Shows the Paper Summary in five sentences.

1. Click 5-Sentences Summary, below Paper Information.
2. Where no Paper Summary is completed, queued or running, click Make Paper Summary.

- A window shows the five sentences as your AI wrote them.
- After a confirmed sign-in or runtime failure, Retry Paper Summary stands instead of Make Paper Summary.
- **Sent:** Make Paper Summary sends the parsed text of every page after the full parsing, else every page's text, without page images.
- **Sent:** Retry Paper Summary sends one new request for this PDF, with the text Make Paper Summary sends.
- **Limit:** Retry Paper Summary is available once per PDF (NOTICE.txt, item 4).
- **If it stops:** at Paper Summary Needs Attention, click it, read why, and use the button it offers.

## 5. Select text: Translate, Ask, Copy, Highlight, Note

Select text in the PDF: a small bar above it holds Translate, Ask, Copy, Highlight and Note. Copy, Highlight and Note send nothing.

A request may add one more request with more source from the same PDF, which can include whole pages as images. If one stops, see Retry (section 7).

### Translate

Translates the selection.

1. Click Translate.

- A card appears under Translate, in the Answer Language of AI Settings.
- **Sent:** the selected text with original images cut from the page. A confirmed continuation from one column to another can be split into separate source images. Image boundaries may include short neighboring text on the same line.

### Ask

Asks your AI about the selection.

1. Click Ask.
2. Type your question, or press Tab for the suggested one, and press Enter.

- The answer comes as a card under Explanation; a notice offers Open.
- The first selection question shows a reminder that Ask may include nearby text or images from the PDF with the selection.
- **Sent:** your question and selection, plus context the Reader can associate with it. After full parsing this can include parsed passages and related Figure, Table or Equation evidence. It is not always limited to the exact selected words or one paragraph.
- **Sent:** before full parsing, available nearby text and images can be used instead.
- Text with a faulty embedded OCR character can differ from the printed page. Compare it with View Original before relying on an answer; a different selection does not repair the original text layer.

### Copy

Copies the selection as one paragraph.

1. Click Copy.

### Highlight

Marks the selection in color.

1. Click Highlight.

- The mark takes the Default Highlight Color of General Settings, yellow at first; its card goes under Notes.
- A click on the mark opens its Request Details, where another of the five colors repaints it.

### Note

Saves your own note on the selection.

1. Click Note.
2. Type the note in Source Note and press Enter.

- The note goes under Notes; Edit, in its Request Details, changes it.

## 6. Sections, Figures, Tables and Equations

Except for Summary and LaTeX, a request may add one more request with more source from the same PDF; for a Figure, Table or Equation it can include whole pages as images.

### Section Summary

Summarizes one section, or answers about it.

1. Click the small logo button beside a section heading.
2. Click Summary, or Ask after the full parsing.

- Summary adds a card under Summary; Ask opens Ask About This Source and answers under Explanation.
- **Sent:** Summary sends the section's text and named Figures' and Tables' text and captions.
- **Sent:** Ask sends its parsed text, Figures it holds or names, and images of such Tables or Equations with unclear parsed text.
- **If it stops:** at Section Is Still Being Prepared, wait until every page's layout is ready.

### Ask on a Figure, Table or Equation

Asks your AI about one Figure, Table or Equation.

1. Point inside it: its bar shows Ask, Copy Image and Save Image, with LaTeX for an Equation and Export Data for a Table.
2. Click Ask.
3. Type your question and press Enter.

- The answer comes under Explanation; a small answer box in its corner or beside it opens its answers.
- Copy Image and Save Image copy or save its picture as cut from the page, and send nothing.
- **Sent:** its image and caption, the paragraphs that refer to it and those around it, as text and images.
- Table questions ask the AI to preserve literal identifiers, units, symbols and qualifications, and to leave unclear cells uncertain. This instruction does not verify the generated values; compare them with the original table.
- **Limit:** a save into a linked or network folder is refused, and no file is replaced.

### LaTeX

Writes an Equation as LaTeX.

1. Point inside the Equation and click LaTeX.

- A card appears under Others; its Request Details shows the LaTeX with a preview and Copy LaTeX.
- **Sent:** the Equation's image with the source the request needs, and after the full parsing its parsed text.

### Export Data

Reads a Table into data.

1. Point inside the Table and click Export Data.

- A card appears under Others; its Request Details shows the table with Save CSV and Save JSON.
- **Sent:** the Table's image cut from the page, with the source the request needs.

## 7. Answers and notes in Assistance & Notes

Only Continue Conversation, New Conversation, Continue Research and Retry send anything here; a request may add one more request with more source from the same PDF.

### Request Details

Shows a card's record in the answer window.

1. Choose Summary, Explanation, Translate, Notes or Others above the list, or type in Search Answers and Notes.
2. Click a card, or Open on a notice.

- The PDF moves to the record's source.
- Copy Markdown, on a completed Explanation, Summary or Translate answer, copies it with its Sources list.

### Notes

Lists your notes and highlights in page order.

1. Click Notes above the list.
2. Choose All, Written Notes, Manual Highlights or Auto Highlights.

### Sources

Shows where an answer's statements come from.

1. Click the folded line under the answer, such as Sources (5) · 1 to check, or a number such as [1].
2. Click a line or number to jump to its place in the PDF.

- Each line gives the number, kind and page, such as [1] Figure 7 · p. 4, and the start of its quotation.
- Check in the paper means the Reader could not match the AI's quotation to that page's text: open the page and check it.
- An answer is held for this cause only when none of its sources matched; a cited Figure or Table image counts as matched.

### Continue Conversation

Asks a follow-up on the same source.

1. In Request Details, click Continue Conversation, or New Conversation on a note or highlight.
2. Type your question and press Enter.

- Continue Research, shown when an answer reports missing source, asks the AI to look further.
- **Sent:** your question with the earlier turns, answer or note and that record's source; for the paper's Summary, every page's text.
- **If it stops:** at Start a New Conversation, click New Conversation.

### Delete Card

Removes a card, a turn or a conversation.

1. Click Delete Card, Delete Turn or Delete Conversation.

- It asks once where text would be lost; a failed, held or canceled card goes at once.

### Retry

Sends a failed or stopped request again.

1. Open the card and read the reason.
2. If the reason names the runtime, check it in AI Settings.
3. Click Retry.

- Cancel on a running card stops it.
- **Sent:** a new request to the selected AI provider, which may incur a charge.

### Reset

Clears this paper's reading records.

1. Click Reset, beside the Assistance & Notes title, then Reset Records.

- What it keeps is in NOTICE.txt, item 5.
- **If it stops:** if Save Failed or Reset failed shows, read the footer's reason and try again.

## 8. Auto Highlight

### Auto Highlight

Marks passages in the colors of Novelty, Methods and Results.

1. After the full parsing, click Auto Highlight in the reading toolbar.
2. For one more pass, click Add Highlights beside it.
3. To remove them, click Delete Auto Highlight and confirm.

- Up to three passes mark up to 30 passages, each with a card marked Auto under Notes.
- A passage the Reader could not match to its page's parsed text or original PDF text is not placed; Workspace lists it by page.
- Cancel Highlight stops a pass and keeps saved highlights.
- **Sent:** each pass sends the full parsed text of the paper; the first click runs up to three passes, Add Highlights one.
- **If it stops:** read the reason in the footer or Workspace, then click Auto Highlight or Add Highlights again.

## 9. HTML Overview

### Make HTML Overview

Saves the paper's overview as an HTML page.

1. After Background Parsing finishes, click HTML Overview.
2. Choose the export folder and check the paper folder name.
3. Click Make HTML Overview.

- It holds the paper information, contents, figures, tables, equations and the newest completed Paper Summary.
- That Paper Summary names the AI runtime and model that wrote it: check it against the paper.
- **Sent:** nothing; the export works offline and makes no AI request.
- **If it stops:** if the folder is unavailable, use Choose Folder; if parsing stopped, use Retry Parsing in Workspace.

## 10. AI Settings, General Settings, Information, Workspace and Parsing Data

These send nothing unless a point below says so.

### AI Settings

Chooses the AI program, model and answer language.

1. Click AI Settings in the footer.
2. Choose the Runtime, Model, Effort and Answer Language.
3. Click Save.

- On first use the Reader selects Codex if both programs are found, else the one found.
- **Detected · Sign-in not checked** means the command-line tool passed its version check. If a request reports a sign-in error, sign in to that selected tool with the intended account, then retry. With several browser accounts, check the account on the sign-in page.
- **If it stops:** if the runtime is Unavailable, install or update Claude Code or Codex (INSTALL_GUIDE.md, section 2) and sign in.

### General Settings

Sets the text size, the Paper Summary switch and the highlight color.

1. Click General Settings in the footer.
2. Set the text size from 70 to 130 percent with Smaller and Larger, or Original Size.
3. Turn Start the Paper Summary by itself on or off.
4. Choose the Default Highlight Color.

- Each choice is kept on this PC.
- **Sent:** turning the switch on starts the open paper's Paper Summary where none was tried, or its Summary Update.

### Information

Holds the Guide, the FAQ and About.

1. Click Information, at the top right.

- The Guide's topics fold under five headings; in the Guide and the FAQ, opening one closes the one that was open.
- Limits and What to Check, under Getting Started, says what parsing and the AI can get wrong and what to check.
- About names the product, version and developer; his homepage, https://hhyang95.com, opens in your web browser.

### Workspace

Shows the work on the open paper.

1. Click the status at the left of the footer.

- It lists Background Parsing, Request Queue, Automatic Summary Update, Highlight Passes and Auto Highlight.
- **Sent:** after Retry Parsing completes, the Summary Update while the switch is on; the lookup of section 1 may run again.
- **If it stops:** at Parsing Needs Attention, read the reason in Workspace and click Retry Parsing.

### Parsing Data

Clears parsing data kept on your PC.

1. Click Parsing Data in the footer.
2. Choose Clear Current PDF, Clear Selected or Clear All Parsing Data.

- Original PDFs, notes and conversations stay; a cleared paper is parsed again when it next opens.
- **If it stops:** if parsing or assistance is still active, wait, then clear again.
