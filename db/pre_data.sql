--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pumpl
--

SELECT pg_catalog.setval('categories_id_seq', 49, true);


--
-- Name: item_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pumpl
--

SELECT pg_catalog.setval('item_types_id_seq', 25, true);


--
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pumpl
--

SELECT pg_catalog.setval('items_id_seq', 774, true);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pumpl
--

SELECT pg_catalog.setval('settings_id_seq', 13, true);


--
-- Name: user_deals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pumpl
--

SELECT pg_catalog.setval('user_deals_id_seq', 116, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pumpl
--

SELECT pg_catalog.setval('users_id_seq', 17, true);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: pumpl
--

COPY categories (id, name, parent_id, created_at, updated_at) FROM stdin;
19	서울	\N	2010-10-16 12:58:33.307415	2010-10-16 12:58:33.307415
20	강남	19	2010-10-16 12:58:39.916247	2010-10-16 12:58:39.916247
21	강북	19	2010-10-16 12:58:46.090062	2010-10-16 12:58:46.090062
22	경기도	\N	2010-10-16 12:58:52.730673	2010-10-16 12:58:52.730673
23	일산	22	2010-10-16 12:59:00.192001	2010-10-16 12:59:00.192001
24	분당	22	2010-10-16 12:59:09.983123	2010-10-16 12:59:09.983123
25	인천	\N	2010-10-16 12:59:14.846626	2010-10-16 12:59:14.846626
26	부산	\N	2010-10-16 12:59:21.05387	2010-10-16 12:59:21.05387
27	대구	\N	2010-10-16 12:59:28.488744	2010-10-16 12:59:28.488744
28	울산	\N	2010-10-16 12:59:33.803068	2010-10-16 12:59:33.803068
29	광주	\N	2010-10-16 12:59:40.933857	2010-10-16 12:59:40.933857
30	대전	\N	2010-10-16 12:59:45.812757	2010-10-16 12:59:45.812757
31	기타	\N	2010-10-16 12:59:54.340197	2010-10-16 12:59:54.340197
49	Other	\N	2010-11-16 15:01:13.383042	2010-11-16 15:01:13.383042
\.


--
-- Data for Name: item_types; Type: TABLE DATA; Schema: public; Owner: pumpl
--

COPY item_types (id, name, created_at, updated_at) FROM stdin;
16	맛집.카페	2010-10-15 05:01:17.852904	2010-10-15 05:01:17.852904
17	술집.와인	2010-10-15 05:01:30.382022	2010-10-15 05:01:30.382022
18	뷰티.생활	2010-10-15 05:01:52.674132	2010-10-15 05:01:52.674132
19	레저.취미	2010-10-15 05:03:48.517368	2010-10-15 05:03:48.517368
20	공연.전시	2010-10-15 05:04:19.84797	2010-10-15 05:04:19.84797
21	여행	2010-10-15 05:04:26.696078	2010-10-15 05:04:26.696078
22	기타	2010-10-15 05:04:29.790905	2010-10-15 05:04:29.790905
25	Other	2010-11-16 15:01:13.426354	2010-11-16 15:01:13.426354
\.


