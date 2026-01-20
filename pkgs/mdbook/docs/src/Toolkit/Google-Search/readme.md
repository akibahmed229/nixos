# Google Search — One-page cheat-sheet

A compact, copy-pasteable markdown cheat-sheet with short explanations and ready examples.

---

## Core operators (fast, precise)

- **`related:`** — Find sites similar to a domain.
  Example: `related:clientwebsite.com`

- **`site:`** — Search only inside a specific website.
  Example: `burnout at work site:hbr.org`

- **`intitle:infographic`** — Pages that call out “infographic” in the title.
  Example: `gdpr intitle:infographic`

- **`filetype:`** — Restrict results to a file format (pdf, docx, ppt).
  Example: `consulting case interview filetype:pdf`

- **`intitle:2022`** — Find pages with a specific year in the title (good for reviews).
  Example: `intitle:2022 laptop for students`

- **`-` (minus)** — Exclude words to reduce noise.
  Example: `meta -facebook`

- **`-site:`** — Exclude an entire domain.
  Example: `data visualization -site:youtube.com -site:pinterest.com`

- **`"exact phrase"`** — Exact-match a full phrase.
  Example: `"that's where google must be down"`

- **`*` (wildcard)** — Placeholder for unknown words.
  Example: `"top * programming languages 2024"`

- **`+`** — Force inclusion / niche focus.
  Example: `app annie +shopping`

- **`OR`** — Return results that match either term.
  Example: `growth marketing OR content marketing OR product marketing`

---

## Region & time filters

- **Country TLD with `site:`** — Limit to country-level domains.
  Example: `vaccine site:.us` or `vaccine site:.fr`

- **Date tools (Google → Tools → Any time)** — Filter by recency (e.g., Past year).
  Example workflow: Search `google tasks tips` → Tools → select `Past year`

---

## Image quick tip

- **Transparent backgrounds** — Images → Tools → Color → Transparent.
  Example: `company logo` → Tools → Color → Transparent

---

## Quick reference (your numbered list mapped to operators)

1. **Exact search:** `"search"`
2. **Site search:** `site:`
3. **Exclude:** `-search`
4. **After date:** `after:YYYY-MM-DD` _(useful for single-date filtering)_
5. **Range:** `YYYY-MM-DD..YYYY-MM-DD` _(or `first..second` for numbers)_
6. **Compare / either/or:** `(A|B) C` or `A OR B C`
7. **Wildcard:** `*search` (use `*` inside phrases)
8. **File type:** `filetype:pdf`

---

## Combine operators — practical combos

- Find recent PDFs from universities:

  ```text
  site:edu filetype:pdf intitle:2023
  ```

- Search product reviews excluding YouTube:

  ```text
  "laptop review" intitle:2024 -site:youtube.com
  ```

- Regional news about vaccines:

  ```text
  vaccine site:.de after:2024-01-01
  ```

- Narrow Q&A on a topic:

  ```text
  "how to build REST API" site:stackoverflow.com
  ```

---

## Copy-paste cheat block

```
related:clientwebsite.com
burnout at work site:hbr.org
gdpr intitle:infographic
consulting case interview filetype:pdf
intitle:2022 laptop for students
meta -facebook
data visualization -site:youtube.com -site:pinterest.com
"that's where google must be down"
"top * programming languages 2024"
app annie +shopping
growth marketing OR content marketing OR product marketing
vaccine site:.us
```
